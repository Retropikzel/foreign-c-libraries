(define-c-library libc '("stdlib.h") #f '())
(define-c-procedure c-system libc 'system 'int '(pointer))

(define (system command)
  (let* ((command-cbv (string->c-bytevector command))
         (result (c-system command-cbv)))
    (c-bytevector-free command-cbv)
    result))
