(define libc-name
  (cond-expand
    (windows "ucrtbase")
    (haiku "root")
    (guile "c")
    (else "c")))
(define-c-library libc
                  '("stdlib.h" "stdio.h" "string.h")
                  libc-name
                  '((additional-versions ("0" "6"))))

(define-c-procedure c-malloc libc 'malloc 'pointer '(int))
(define-c-procedure c-free libc 'free 'void '(pointer))
(define-c-procedure c-strlen libc 'strlen 'int '(pointer))
(define-c-procedure c-memset-address->pointer libc 'memset 'pointer '(uint64 uint8 int))
;; FIXME uint64 does not work on Chibi
;(define-c-procedure c-memset-pointer->address libc 'memset 'uint64 '(pointer uint8 int))
(define-c-procedure c-memset-pointer->address libc 'memset 'int '(pointer uint8 int))
(define (make-c-null) (c-memset-address->pointer 0 0 0))
(define c-null?
  (lambda (pointer)
    (call-with-current-continuation
      (lambda (k)
        (with-exception-handler
          (lambda (x) (k #f))
          (lambda () (= (c-memset-pointer->address pointer 0 0) 0)))))))
