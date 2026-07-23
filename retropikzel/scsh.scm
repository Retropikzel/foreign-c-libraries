(define-c-library libc '("stdlib.h" "string.h" "stdio.h") #f ())

;(define-c-procedure c-setenv libc 'setenv 'int '(pointer pointer int))

(define (setenv var val)
  (when (not (string? var)) (error "setenv error: var must be string"))
  (when (not (string? val)) (error "setenv error: val must be string"))
  (set-environment-variable! var val))
