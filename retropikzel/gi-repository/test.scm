
(test-begin "gi-repository")

(define repository (gi-repository-new))
(display repository)
(newline)

(define err (make-c-null))

(call-with-address-of
  err
  (lambda (err-address)
    (gi-repository-require repository
                           (string->c-utf8 "GLib")
                           (string->c-utf8 "2.0")
                           0
                           err-address)
    (when (not (c-null? err))
      (error "gi-repository-require failed"))))


(define base-info
  (gi-repository-find-by-name repository
                              (string->c-utf8 "GLib")
                              (string->c-utf8 "assertion_message")))

(when (c-null? base-info) (error "base-info failed"))

(define args (make-c-bytevector (* (c-type-size 'pointer) 5)))

(c-bytevector-pointer-set! args 0 (string->c-utf8 "domain"))
(c-bytevector-pointer-set! args (c-type-size 'pointer) (string->c-utf8 "(retropikzel gi-repository)"))
(c-bytevector-u8-set! args (* (c-type-size 'pointer) 2) 42)
(c-bytevector-pointer-set! args (* (c-type-size 'pointer) 3) (string->c-utf8 "test.scm"))
(c-bytevector-pointer-set! args (* (c-type-size 'pointer) 4) (string->c-utf8 "foobar"))

(define return-value (make-c-bytevector (c-type-size 'int)))
(define invoke-err (make-c-null))
(call-with-address-of
  invoke-err
  (lambda (invoke-err-address)
    (let ((return-code
            (gi-function-info-invoke base-info
                                     args
                                     5
                                     (make-c-null)
                                     0
                                     (make-c-null)
                                     invoke-err-address)))
      (display "HERE: ")
      (write return-code)
      (newline)
      )))

(test-end "gi-repository")
