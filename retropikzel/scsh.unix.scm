(define-c-library libc '("stdlib.h" "string.h" "stdio.h" "glob.h") #f ())

;(define-c-procedure c-setenv libc 'setenv 'int '(pointer pointer int))

(define (setenv var val)
  (when (not (string? var)) (error "setenv error: var must be string"))
  (when (not (string? val)) (error "setenv error: val must be string"))
  (set-environment-variable! var val))

(define getenv get-environment-variable)

(define-c-procedure c-glob libc 'glob 'int '(pointer int pointer pointer))
(define-c-procedure c-globfree libc 'globfree 'int '(pointer))
(define-c-struct-type glob-struct '((gl_pathc int) (gl_pathv pointer) (gl_offs int)))
(define glob
  (lambda paths
    (let ((result '()))
      (for-each
        (lambda (path)
          (let ((glob-struct-cbv (make-c-bytevector (c-type-size glob-struct)))
                (path-cbv (string->c-bytevector path)))
            (c-glob path-cbv 0 glob-struct-cbv)
            (display "HERE: path ")
            (display path)
            (newline)
            (c-bytevector-free path-cbv)
            ))
        paths))))
