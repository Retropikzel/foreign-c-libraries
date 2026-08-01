(define (reduce-port port reader op . seeds)
  (letrec* ((looper (lambda new-seeds
                      (let ((read-value (reader port)))
                        (if (eof-object? read-value)
                          (apply values new-seeds)
                          (call-with-values (lambda ()
                                              (apply op read-value new-seeds))
                                            looper))))))
    (apply looper seeds)))

(define port-fold reduce-port)

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

