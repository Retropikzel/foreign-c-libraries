;;;; This file is dependent on content of other files added trough (include...)
;;;; And that's why it is separated

(define make-c-function
  (lambda (shared-object c-name return-type argument-types)
    (dlerror) ;; Clean all previous errors
    (let ((c-function (dlsym shared-object c-name))
          (maybe-dlerror (dlerror)))
      (lambda arguments
        (let ((return-pointer (internal-ffi-call (length argument-types)
                                                 (type->libffi-type-number return-type)
                                                 (map type->libffi-type-number argument-types)
                                                 c-function
                                                 (size-of-type return-type)
                                                 arguments)))
          (c-bytevector-get return-pointer return-type 0))))))

(define-syntax define-c-procedure
  (syntax-rules ()
    ((_ scheme-name shared-object c-name return-type argument-types)
     (define scheme-name
       (make-c-function shared-object
                        (symbol->string c-name)
                        return-type
                        argument-types)))))
