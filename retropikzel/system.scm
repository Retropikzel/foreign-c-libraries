(define-c-library libc '("stdlib.h") #f '())
(define-c-procedure c-system libc 'system 'int '(pointer))

(define (system command)
  (let* ((command-pointer (string->c-bytevector command))
         (result (c-system command-pointer)))
    (c-bytevector-free command-pointer)
    result))
