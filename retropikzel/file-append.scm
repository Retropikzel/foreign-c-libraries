(define-c-library libc '("stdio.h") #f ())

(define-c-procedure c-fopen libc 'fopen 'pointer '(pointer pointer))
(define-c-procedure c-fwrite libc 'fwrite 'int '(pointer int int pointer))
(define-c-procedure c-fclose libc 'fclose 'int '(pointer))

(define mode-cbv (string->c-bytevector "a"))

(define (with-append-to-file path thunk)
  (let* ((path-cbv (string->c-bytevector path))
         (file-cbv (c-fopen path-cbv mode-cbv))
         (output (parameterize ((current-output-port (open-output-string)))
                   (apply thunk '())
                   (get-output-string (current-output-port))))
         (output-cbv (string->c-bytevector output))
         (output-length (string-length output)))
    (c-fwrite output-cbv 1 output-length file-cbv)
    (c-fclose file-cbv)
    (c-bytevector-free path-cbv output-cbv)))
