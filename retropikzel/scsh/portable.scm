(define (port-fold port reader op . seeds)
  (letrec* ((looper (lambda new-seeds
                      (let ((read-value (reader port)))
                        (if (eof-object? read-value)
                          (apply values new-seeds)
                          (call-with-values (lambda ()
                                              (apply op read-value new-seeds))
                                            looper))))))
    (apply looper seeds)))

(define reduce-port port-fold)

(define (simplify-file-name fname) ;; TODO
  (cond
    ((not (string? fname))
     (error "simplify-file-name error: fname must be string"))
    (else fname)))

(define set-umask set-umask!)

(define (setenv var val)
  (when (not (string? var)) (error "setenv error: var must be string"))
  (when (not (string? val)) (error "setenv error: val must be string"))
  (set-environment-variable! var val))

(define getenv get-environment-variable)

(define (glob-quote str)
  (list->string
    (apply
      append
      (map
        (lambda (c)
          (if (member c (list #\*))
            (list #\\ c)
            (list c)))
        (string->list str)))))

(define (add-after elt after lst)
  (apply
    append
    (map
      (lambda (item)
        (if (equal? item after)
          (list item elt)
          (list item)))
      lst)))

(define (add-before elt after lst)
  (apply
    append
    (map
      (lambda (item)
        (if (equal? item after)
          (list elt item)
          (list item)))
      lst)))

(define (alist->env alist)
  (map (lambda (item)
         (cond
           ((not (pair? item))
            (error "alist->env error: alist items must be pairs" item))
           ((not (string? (car item)))
            (error "alist->env error: alist item car must be string" item))
           ((and (not (string? (cdr item)))
                 (not (list? (cdr item))))
            (error (string-append "alist->env error: alist item cdr must be"
                                  "string or list of strings")
                   item))
           ((string? (cdr item))
            (string-append (car item) "=" (cdr item)))
           ((list? (cdr item))
            (for-each
              (lambda (cdr-list-item)
                (when (not (string? cdr-list-item))
                  (error (string-append "alist->env errror: all cdr list"
                                        " items must be strings"
                                        item))))
              (cdr item))
            (string-append (car item) "=" (string-join (cdr item) ":")))
           (else (error "alist->env error: unexpected error" alist))))
       alist))

(define (alist-compress alist)
  (let ((result '()))
    (for-each
      (lambda (item)
        (when (not (member item result))
          (set! result (cons item result))))
      alist)
    (reverse result)))

(define (alist-delete key alist)
  (let ((result '()))
    (for-each
      (lambda (item)
        (when (not (equal? key (car item)))
          (set! result (cons item result))))
      alist)
    (reverse result)))

(define (alist-update key val alist)
  (cons (cons key val) (alist-delete key alist)))

(define (arg arglist n . default)
  (when (not (list? arglist)) (error "arg error: arglist must be list"))
  (when (not (integer? n)) (error "arg error: n must be integer"))
  (when (< n 1) (error "arg error: Index starts from 1"))
  (if (and (< (length arglist) n)
           (not (null? default)))
    (car default)
    (list-ref arglist (- n 1))))

(define (arg* arglist n . default-thunk)
  (when (not (list? arglist)) (error "arg* error: arglist must be list"))
  (when (not (integer? n)) (error "arg* error: n must be integer"))
  (when (< n 1) (error "arg* error: Index starts from 1"))
  (if (and (< (length arglist) n)
           (not (null? default-thunk)))
    (begin
      (when (not (procedure? (car default-thunk)))
        (error "arg* error: default-tunk must be procedure"))
      (apply (car default-thunk) '()))
    (list-ref arglist (- n 1))))

(define (argv n)
  (when (not (integer? n)) (error "argv error: n must be integer"))
  (arg (command-line) (+ n 1)))

(define current-autoreap-policy 'wait)
(define autoreap-policy
  (lambda args
    (cond
      ((null? args) current-autoreap-policy)
      (else
        (when (not (or (equal? (car args) 'early)
                       (equal? (car args) 'late)
                       (equal? (car args) #f)))
          (error "autoreap-policy error: policy must be 'early, 'late or #f"
                 (car args)))
        (set! current-autoreap-policy (car args))))))

(define (sleep time)
  (when (not (integer? time)) (error "sleep error: time must be integer" time))
  (letrec*
    ((end-time
       (let ((end-time (current-time))
             (seconds (quotient time 1000))
             (nanoseconds (* (remainder time 1000) 1000000)))
         (set-time-second! end-time (+ (time-second end-time) seconds))
         (set-time-nanosecond! end-time (+ (time-nanosecond end-time) nanoseconds))
         end-time))
     (looper (lambda () (when (time<? (current-time) end-time) (looper)))))
    (looper)))

(define (process-sleep secs)
  (when (not (integer? secs))
    (error "process-sleep error: secs must be integer" secs))
  (sleep (* secs 1000)))

(define (call-terminally thunk)
  (when (not (procedure? thunk))
    (error "call-terminally error: thunk must be procedure" thunk))
  (thunk)
  (exit 0))

(define (call-with-string-output-port procedure)
  (when (not (procedure? procedure))
    (error (string-append "call-with-string-output-port error: procedure"
                          " argument must be type of procedure")
           procedure))
  (let ((port (open-output-string)))
    (procedure port)
    (get-output-string port)))

(define (char-ascii? character)
  (when (not (char? character))
    (error "char-ascii? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:ascii character))

(define (char-blank? character)
  (when (not (char? character))
    (error "char-blank? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:blank character))

(define (char-digit? character)
  (when (not (char? character))
    (error "char-digit? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:digit character))

(define (char-graphic? character)
  (when (not (char? character))
    (error "char-graphic? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:graphic character))

(define (char-hex-digit? character)
  (when (not (char? character))
    (error "char-hex-digit? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:hex-digit character))

(define (char-iso-control? character)
  (when (not (char? character))
    (error "char-iso-control? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:iso-control character))

(define (char-letter+digit? character)
  (when (not (char? character))
    (error "char-letter+digit? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:letter+digit character))

(define (char-letter? character)
  (when (not (char? character))
    (error "char-letter? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:letter character))

(define (char-printing? character)
  (when (not (char? character))
    (error "char-printing? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:printing character))

(define (char-punctuation? character)
  (when (not (char? character))
    (error "char-punctuation? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:punctuation character))

(define (char-title-case? character)
  (when (not (char? character))
    (error "char-title-case? error: character argument must be of type character"
           character))
  (char-set-contains? char-set:title-case character))

(define (command-line-arguments)
  (cdr (command-line)))

(define (directory-as-file-name fname)
  (cond
    ((not (string? fname))
      (error "directory-as-file-name error: fname must be string" fname))
    ((string=? fname "/")
     "/")
    ((string=? fname "")
     ".")
    (else
      (let ((fname-length (string-length fname)))
        (if (char=? (string-ref fname (- fname-length 1)) #\/)
          (string-copy fname 0 (- fname-length 1))
          fname)))))

(define (env->alist str)
    (map (lambda (item)
           (apply cons (string-split item #\=)))
      (string-split str #\newline)))

(define (error-output-port) (current-error-port))

(define (file-last-access fname/port follow?)
  (let* ((fi (file-info fname/port follow?)))
    (file-info:atime fi)))

(define (file-last-mod fname/port follow?)
  (let* ((fi (file-info fname/port follow?)))
    (file-info:mtime fi)))

(define (file-last-status-change fname/port follow?)
  (let* ((fi (file-info fname/port follow?)))
    (file-info:ctime fi)))

(define (file-mode fname/port follow?)
  (let* ((fi (file-info fname/port follow?)))
    (file-info:mode fi)))

(define (file-name-absolute? fname)
  (when (not (string? fname))
    (error "file-name-absolute? error: fname must be string" fname))
  (if (string=? fname "")
    #t
    (path-absolute? fname)))

(define (file-name-as-directory fname)
  (when (not (string? fname))
    (error "file-name-as-directory error: fname must be string" fname))
  (cond ((string=? fname ".") "")
        ((string=? fname "/") "/")
        ((string=? fname "") "/")
        ((char=? (string-ref fname (- (string-length fname) 1)) #\/) fname)
        (else (string-append fname "/"))))

(define (file-name-directory fname)
  (when (not (string? fname))
    (error "file-name-directory error: fname must be string" fname))
  (cond ((string=? fname "/") "")
        ((string=? fname "") "")
        ((char=? (string-ref fname (- (string-length fname) 1)) #\/) fname)
        (else
          (let ((chibi-path (path-directory fname)))
            (if (string=? chibi-path ".")
              ""
              (string-append chibi-path "/"))))))

(define (file-name-directory? fname)
  (when (not (string? fname))
    (error "file-name-directory? error: fname must be string" fname))
  (cond ((string=? fname "/") #t)
        ((string=? fname ".") #f)
        ((string=? fname "") #t)
        (else (char=? (string-ref fname (- (string-length fname) 1)) #\/))))

(define (file-name-extension fname)
  (when (not (string? fname))
    (error "file-name-extension error: fname must be string" fname))
  (let ((extension (path-extension fname)))
    (if extension (string-append "." extension) "")))

(define (file-name-non-directory? fname)
  (when (not (string? fname))
    (error "file-name-non-directory? error: fname must be string" fname))
  (if (string=? fname "") #t (not (file-name-directory? fname))))

(define (file-name-nondirectory fname)
  (when (not (string? fname))
    (error "file-name-nondirectory error: fname must be string" fname))
  (cond ((string=? fname "/") "/")
        (else (path-strip-directory fname))))

(define (file-name-sans-extension fname)
  (when (not (string? fname))
    (error "file-name-sans-extension error: fname must be string" fname))
  (path-strip-extension fname))

(define (file-nlinks fname/port follow?)
  (let* ((fi (file-info fname/port follow?)))
    (file-info:nlinks fi)))

(define (file-owner fname/port follow?)
  (let* ((fi (file-info fname/port follow?)))
    (file-info:uid fi)))

(define (file-size fname/port follow?)
  (let* ((fi (file-info fname/port follow?)))
    (file-info:size fi)))

(define home-directory (get-environment-variable "HOME"))

(define home-file
  (lambda args
    (when (and (= (length args) 1) (not (string? (car args))))
      (error "home-file error: fname must be string"))
    (when (and (= (length args) 2) (not (string? (list-ref args 0))))j
      (error "home-file error: user must be string"))
    (when (and (= (length args) 2) (not (string? (list-ref args 1))))
      (error "home-file error: user must be string"))
    (let ((dir (if (= (length args) 2)
                 (home-dir (car args))
                 (home-dir)))
          (fname (if (= (length args) 2)
                   (home-dir (list-ref args 1))
                   (home-dir))))
      (string-append dir "/" fname))))

(define (make-char-port-filter filter)
  (lambda ()
    (letrec* ((looper (lambda (c)
                        (when (not (eof-object? c))
                          (write-char (filter c))
                          (looper (read-char))))))
      (looper (read-char)))))

(define (make-string-input-port str) (open-input-string str))

(define (make-string-output-port str) (open-output-string str))

(define (make-string-port-filter filter . args)
  (lambda ()
    (letrec* ((buflen
                (cond ((and (= (length args) 1)
                            (not (integer? (car args))))
                       (error (string-append "make-string-port-filter error:"
                                             " buflen must be integer" )))
                      ((and (= (length args) 1)) (car args))
                      (else 1024)))
              (looper (lambda (str)
                        (when (not (eof-object? str))
                          (display (filter str))
                          (looper (read-string buflen))))))
      (looper (read-string buflen)))))

(define (os)
  (cond-expand
    (linux 'linux)
    (freebsd 'freesdb)
    (netbsd 'netbsd)
    (haiku 'haiku)
    (else 'unix)))

(define (parse-file-name fname)
  (when (not (string? fname))
    (error "parse-file-name error: fname must be string" fname))
  (let ((f (file-name-nondirectory fname)))
    (list (file-name-directory fname)
          (file-name-sans-extension f)
          (file-name-extension f))))

(define (path-list->file-name path-list . args)
  (let ((path (string-join path-list "/")))
  (cond ((null? path-list) "")
        ((and (not (null? args))
              (string=? (car args) ""))
         (string-append "/" path))
        ((and (not (null? args))
              (not (string? (car args))))
         (error "path-list->file-name error: dir must be string"
                (car args)))
        ((and (not (null? args))
              (string? (car args)))
         (string-append (file-name-as-directory (car args)) path))
        (else path))))

(define (port->list reader port)
  (reverse (port-fold port reader cons '())))

(define (port->sexp-list port) (port->list read port))

(define (port->string port)
  (letrec* ((result "")
            (looper (lambda (str)
                      (cond ((eof-object? str) result)
                            (else (set! result (string-append result str))
                                  (looper (read-string 1024 port)))))))
    (looper (read-string 1024 port))))

(define (port->string-list port) (reverse (port-fold port r7rs-read-line cons '())))

(define (read-delimited char-set . args)

  (when (and (not (string? char-set))
             (not (char-set? char-set)))
    (error (string-append "read-delimited error: char-set must be either"
                          " string or char-set")))

  (when (and (> (length args) 0)
             (not (port? (car args))))
    (error (string-append "read-delimited error: port must of type port")))

  (when (and (> (length args) 1)
             (not (member (list-ref args 1) '(trim peek concat split))))
    (error (string-append "read-delimited error: handle-delim must be either"
                          " 'trim, 'peek, 'concat or 'split")
           (list-ref args 1)))

  (letrec* ((character-set (if (string? char-set)
                             (string->char-set char-set)
                             char-set))
            (port (if (> (length args) 0) (car args) (current-input-port)))
            (handle-delim (if (> (length args) 1) (list-ref args 1) 'trim))
            (result '())
            (in-char-set? (lambda (c) (char-set-contains? character-set c)))
            (looper (lambda (c)
                      (cond ((in-char-set? c)
                             (cond ((equal? handle-delim 'trim)
                                    (list->string (reverse result)))
                                   ((equal? handle-delim 'concat)
                                    (list->string (reverse (cons c result))))
                                   ((equal? handle-delim 'split)
                                    (values (list->string (reverse result)) c))))
                            ((and (equal? handle-delim 'peek)
                                  (in-char-set? (peek-char port)))
                             (list->string (reverse (cons c result))))
                            (else (set! result (cons c result))
                                  (looper (read-char port)))))))
    (looper (read-char port))))

(define read-line
  (lambda args

    (when (and (> (length args) 0)
               (not (port? (car args))))
      (error (string-append "read-delimited error: port must of type port")))

    (when (and (> (length args) 1)
               (not (member (list-ref args 1) '(trim peek concat split))))
      (error (string-append "read-line error: handle-delim must be either"
                            " 'trim, 'peek, 'concat or 'split")
             (list-ref args 1)))

    (apply read-delimited (cons (string #\newline) args))))

;; IN PROGRESS
#|
(define read-paragraph
  (lambda args

    (when (and (> (length args) 0)
               (not (port? (car args))))
      (error (string-append "read-delimited error: port must of type port")))

    (when (and (> (length args) 1)
               (not (member (list-ref args 1) '(trim concat split))))
      (error (string-append "read-paragraph error: handle-delim must be either"
                            " 'trim, 'concat or 'split (peek not supported)")
             (list-ref args 1)))

    (letrec*
      ((port (if (> (length args) 0) (car args) (current-input-port)))
       (handle-delim (if (> (length args) 1) (list-ref args 1) 'trim))
       (result '())
       (skipped-blank-lines? #f)
       (looper (lambda (line)
                 (cond ((and (eof-object? line) (null? result)) line)
                       ((and (not skipped-blank-lines?) (string=? line ""))
                        (looper (read-line port handle-delim)))
                       ((and (not (string=? line ""))
                             (equal handle-delim 'trim))
                        (set! result line result))
                       ((and (not (string=? line ""))
                             (equal handle-delim 'concat))
                        (set! result (string-append line "\n") result))



    ))

|#
