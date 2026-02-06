(define CURLOPT-POSTFIELDSIZE 60)
(define CURLOPT-POSTFIELDS 10015)
(define CURLOPT-URL 10002)
(define CURLOPT-HTTPHEADER 10023)
(define CURLOPT-WRITEDATA 10001)
(define CURLOPT-CUSTOMREQUEST 10036)
(define CURLOPT-COOKIE 10022)
(define CURLOPT-COOKIEFILE 10031)
(define CURLOPT-COOKIEJAR 10082)
(define CURLINFO-RESPONSE-CODE 2097154)
(define CURLHE-BADINDEX 1)
(define CURLHE-HEADER 1)
(define CURLINFO-COOKIELIST 4194332)
(define randomized? #f)

(define-c-library libc '("stdlib.h" "stdio.h" "time.h") libc-name '((additional-versions ("6"))))
(define-c-procedure c-fopen libc 'fopen 'pointer '(pointer pointer))
(define-c-procedure c-fclose libc 'fclose 'int '(pointer))
(define-c-procedure c-time libc 'time 'int '(pointer))
(define-c-procedure c-srand libc 'srand 'void '(int))
(define-c-procedure c-rand libc 'rand 'int '())

(define-c-library libcurl '("curl/curl.h") "curl" '((additional-versions ("4" "8"))))
(define-c-procedure curl-easy-init libcurl 'curl_easy_init 'pointer '())
(define-c-procedure curl-easy-setopt-pointer libcurl 'curl_easy_setopt 'int '(pointer int pointer))
(define-c-procedure curl-easy-setopt-int libcurl 'curl_easy_setopt 'int '(pointer int int))
(define-c-procedure curl-slist-append libcurl 'curl_slist_append 'pointer '(pointer pointer))
(define-c-procedure curl-easy-strerror libcurl 'curl_easy_strerror 'pointer '(int))
(define-c-procedure curl-easy-perform libcurl 'curl_easy_perform 'int '(pointer))
(define-c-procedure curl-easy-getinfo libcurl 'curl_easy_getinfo 'int '(pointer int pointer))
(define-c-procedure curl-easy-nextheader libcurl 'curl_easy_nextheader 'pointer '(pointer int int pointer))

(define-record-type response
  (make-response bytes
                 ;cookies
                 headers
                 status-code
                 text
                 url
                 download-path)
  response?
  (bytes response-bytes)
  ;(cookies response-cookies)
  (headers response-headers)
  (status-code response-status-code)
  (text response-text)
  (url response-url)
  (download-path response-download-path))

(define (random-to max)
  (when (not randomized?)
    (c-srand (c-time (make-c-null)))
    (set! randomized? #t))
  (modulo (c-rand) max))

(define (random-string size)
  (letrec
    ((looper
       (lambda (result integer)
         (cond ((= (string-length result) size) result)
               ((or (< integer 0)
                    (> integer 128))
                (looper result (random-to 128)))
               (else
                 (let ((char (integer->char integer)))
                   (if (not (or (char-alphabetic? char)
                                (char-numeric? char)))
                     (looper result (c-rand))
                     (looper (string-append result
                                            (string (integer->char integer)))
                             (random-to 128)))))))))
    (looper "" (random-to 128))))

(define (random-temp-file)
  (string-append (cond-expand (windows (get-environment-variable "TMP"))
                              (else "/tmp"))
                 "/scheme-requests-tmp-"
                 (random-string 6)))

(define handle-errors
  (lambda (result)
    (when (not (= result 0))
      (error (c-utf8->string (curl-easy-strerror result))))
    result))

(define handle (curl-easy-init))

(define (slurp path)
  (with-input-from-file
    path
    (lambda ()
      (letrec
        ((looper (lambda (result text)
                   (if (eof-object? text)
                     result
                     (looper (string-append result text)
                             (read-string 4000))))))
        (looper "" (read-string 4000))))))

(define (slurp-bytes path)
  (let ((port (open-binary-input-file path)))
    (letrec
      ((looper (lambda (result bytes)
                 (cond ((eof-object? bytes)
                        (close-port port)
                        result)
                       (else
                         (looper (bytevector-append result bytes)
                                 (read-bytevector 4000 port)))))))
      (looper (bytevector) (read-bytevector 4000 port)))))

(define (get-status-code handle)
  (let* ((pointer-size (c-type-size 'long))
         (pointer (make-c-bytevector (c-type-size 'long))))
    (curl-easy-getinfo handle CURLINFO-RESPONSE-CODE pointer)
    (let ((code (c-bytevector-ref pointer 'int 0)))
      (c-free pointer)
      code)))

(define (set-body handle body)
  (curl-easy-setopt-pointer handle CURLOPT-POSTFIELDS (string->c-utf8 body))
  (curl-easy-setopt-int handle CURLOPT-POSTFIELDSIZE (string-length body)))

(define (set-headers handle headers)
  (let ((headers-slist (make-c-null)))
    (for-each
      (lambda (header)
        (set! headers-slist
          (curl-slist-append
            headers-slist
            (string->c-utf8 (string-append (if (symbol? (car header))
                                             (symbol->string (car header))
                                             (car header))
                                           ":"
                                           (if (symbol? (cdr header))
                                             (symbol->string (cdr header))
                                             (cdr header)))))))
      headers)
    (curl-easy-setopt-pointer handle CURLOPT-HTTPHEADER headers-slist)))

(define (get-headers handle previous-header-struct result)
  (let* ((header-struct (curl-easy-nextheader handle
                                              CURLHE-HEADER
                                              0
                                              previous-header-struct)))
    (if (c-null? header-struct)
      result
      (let* ((name
               (string->symbol
                 (string-downcase
                   (c-utf8->string
                     (c-bytevector-ref header-struct 'pointer 0)))))
             (value (c-utf8->string (c-bytevector-ref header-struct
                                                      'pointer
                                                      (c-type-size 'pointer)))))
        (get-headers handle header-struct (append result
                                                  (list (cons name value))))))))

(define (copy-string-until str begin-index char)
  (let ((result (list)))
    (call-with-current-continuation
      (lambda (return)
        (string-for-each
          (lambda (c)
            (if (char=? c char)
              (return #t)
              (set! result (cons c result))))
          (string-copy str begin-index))))
    (list->string (reverse result))))

(define (set-cookies handle cookies)
  (let ((cookies-string ""))
    (for-each
      (lambda (header)
        (set! cookies-string
          (string-append cookies-string
                         (if (symbol? (car header))
                           (symbol->string (car header))
                           (car header))
                         "="
                         (if (symbol? (cdr header))
                           (symbol->string (cdr header))
                           (cdr header))
                         "; ")))
      cookies)
    (curl-easy-setopt-pointer handle CURLOPT-COOKIE (string->c-utf8 cookies-string))))

(define request
  (lambda (method url . options)
    (let* ((cookies (assoc 'cookies options))
           (headers (assoc 'headers options))
           (body (assoc 'body options))
           (download-path (assoc 'download-path options))
           (tmp-file-path (if download-path
                            (cdr download-path)
                            (random-temp-file)))
           (tmp-file (c-fopen (string->c-utf8 tmp-file-path)
                              (string->c-utf8 "w"))))
      (curl-easy-setopt-pointer handle
                                CURLOPT-CUSTOMREQUEST
                                (string->c-utf8
                                  (string-upcase (symbol->string method))))
      (curl-easy-setopt-pointer handle CURLOPT-WRITEDATA tmp-file)
      (curl-easy-setopt-pointer handle CURLOPT-URL (string->c-utf8 url))
      (when headers (set-headers handle (cdr headers)))
      (when cookies (set-cookies handle (cdr cookies)))
      (when body (set-body handle (cdr body)))
      (handle-errors (curl-easy-perform handle))
      (c-fclose tmp-file)
      (let* ((headers (get-headers handle (make-c-null) (list)))
             (response (make-response (slurp-bytes tmp-file-path)
                                      ;(get-cookies handle)
                                      headers
                                      (get-status-code handle)
                                      (slurp tmp-file-path)
                                      url
                                      download-path)))
        (if (not download-path) (delete-file tmp-file-path))
        response))))
