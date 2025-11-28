(define-c-library libc '("stdlib.h") libc-name '((additional-versions ("6"))))
(define-c-procedure c-system libc 'system 'int '(pointer))

(define (system command)
  (let* ((command-pointer (string->c-utf8 command))
         (result (c-system command-pointer)))
    (c-free command-pointer)
    result))
