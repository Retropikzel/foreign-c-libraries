(define-c-library libc '("stdio.h") #f ())

(define-c-procedure c-fopen libc 'fopen 'pointer '(pointer pointer))
(define-c-procedure c-fputc libc 'fputc 'int '(int pointer))
(define-c-procedure c-fclose libc 'fclose 'int '(pointer))

(define mode-cbv (string->c-bytevector "a"))

(define (with-append-to-file path thunk)
  (let* ((path-cbv (string->c-bytevector path))
         (file-cbv (c-fopen path-cbv mode-cbv)))
    (string-for-each
      (lambda (c)
        (c-fputc (char->integer c) file-cbv))
      (parameterize ((current-output-port (open-output-string)))
        (apply thunk '())
        (get-output-string (current-output-port))))
    (c-fclose file-cbv)
    (c-bytevector-free path-cbv)))
