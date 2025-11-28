(define-syntax type->native-type
  (syntax-rules ()
    ((_ type)
     ;; This is defined in 3 places
     (cond ((equal? type 'int8) 'integer-8)
           ((equal? type 'uint8) 'unsigned-8)
           ((equal? type 'int16) 'integer-16)
           ((equal? type 'uint16) 'unsigned-16)
           ((equal? type 'int32) 'integer-32)
           ((equal? type 'uint32) 'unsigned-32)
           ((equal? type 'int64) 'integer-64)
           ((equal? type 'uint64) 'unsigned-64)
           ((equal? type 'char) 'char)
           ((equal? type 'unsigned-char) 'unsigned-8)
           ((equal? type 'short) 'short)
           ((equal? type 'unsigned-short) 'unsigned-short)
           ((equal? type 'int) 'int)
           ((equal? type 'unsigned-int) 'unsigned-int)
           ((equal? type 'long) 'long)
           ((equal? type 'unsigned-long) 'unsigned-long)
           ((equal? type 'float) 'float)
           ((equal? type 'double) 'double)
           ((equal? type 'pointer) 'void*)
           ((equal? type 'void) 'void)
           (error "Unsupported type: " type)))))

(define c-bytevector?
  (lambda (object)
    (ftype-pointer? object)))

(define-syntax define-macro!
  (lambda (x)
    (syntax-case x ()
                 [(k (name arg1 ... . args)
                     form1
                     form2
                     ...)
                  #'(k name (arg1 ... . args)
                       form1
                       form2
                       ...)]
                 [(k (name arg1 arg2 ...)
                     form1
                     form2
                     ...)
                  #'(k name (arg1 arg2 ...)
                       form1
                       form2
                       ...)]
                 [(k name args . forms)
                  (identifier? #'name)
                  (letrec ((add-car
                             (lambda (access)
                               (case (car access)
                                 ((cdr) `(cadr ,@(cdr access)))
                                 ((cadr) `(caadr ,@(cdr access)))
                                 ((cddr) `(caddr ,@(cdr access)))
                                 ((cdddr) `(cadddr ,@(cdr access)))
                                 (else `(car ,access)))))
                           (add-cdr
                             (lambda (access)
                               (case (car access)
                                 ((cdr) `(cddr ,@(cdr access)))
                                 ((cadr) `(cdadr ,@(cdr access)))
                                 ((cddr) `(cdddr ,@(cdr access)))
                                 ((cdddr) `(cddddr ,@(cdr access)))
                                 (else `(cdr ,access)))))
                           (parse
                             (lambda (l access)
                               (cond
                                 ((null? l) '())
                                 ((symbol? l) `((,l ,access)))
                                 ((pair? l)
                                  (append!
                                    (parse (car l) (add-car access))
                                    (parse (cdr l) (add-cdr access))))
                                 (else
                                   (syntax-error #'args
                                                 (format "invalid ~s parameter syntax" (datum k))))))))
                    (with-syntax ((proc (datum->syntax-object #'k
                                                              (let ((g (gensym)))
                                                                `(lambda (,g)
                                                                   (let ,(parse (datum args) `(cdr ,g))
                                                                     ,@(datum forms)))))))
                                 #'(define-syntax name
                                     (lambda (x)
                                       (syntax-case x ()
                                                    ((k1 . r)
                                                     (datum->syntax-object #'k1
                                                                           (proc (syntax-object->datum x)))))))))])))

(define-macro!
  define-c-procedure
  (scheme-name shared-object c-name return-type argument-types)
  (let ((native-argument-types
          (map (lambda (type)
                 ;; This is defined in 3 places
                 (cond ((equal? type 'int8) 'integer-8)
                       ((equal? type 'uint8) 'unsigned-8)
                       ((equal? type 'int16) 'integer-16)
                       ((equal? type 'uint16) 'unsigned-16)
                       ((equal? type 'int32) 'integer-32)
                       ((equal? type 'uint32) 'unsigned-32)
                       ((equal? type 'int64) 'integer-64)
                       ((equal? type 'uint64) 'unsigned-64)
                       ((equal? type 'char) 'char)
                       ((equal? type 'unsigned-char) 'unsigned-8)
                       ((equal? type 'short) 'short)
                       ((equal? type 'unsigned-short) 'unsigned-short)
                       ((equal? type 'int) 'int)
                       ((equal? type 'unsigned-int) 'unsigned-int)
                       ((equal? type 'long) 'long)
                       ((equal? type 'unsigned-long) 'unsigned-long)
                       ((equal? type 'float) 'float)
                       ((equal? type 'double) 'double)
                       ((equal? type 'pointer) 'void*)
                       ((equal? type 'void) 'void)
                       (else type)))
               (if (null? argument-types)
                 '()
                 (cadr argument-types))))
        (native-return-type
          ;; This is defined in 3 places
          (cond ((equal? return-type ''int8) 'integer-8)
                ((equal? return-type ''uint8) 'unsigned-8)
                ((equal? return-type ''int16) 'integer-16)
                ((equal? return-type ''uint16) 'unsigned-16)
                ((equal? return-type ''int32) 'integer-32)
                ((equal? return-type ''uint32) 'unsigned-32)
                ((equal? return-type ''int64) 'integer-64)
                ((equal? return-type ''uint64) 'unsigned-64)
                ((equal? return-type ''char) 'char)
                ((equal? return-type ''unsigned-char) 'unsigned-8)
                ((equal? return-type ''short) 'short)
                ((equal? return-type ''unsigned-short) 'unsigned-short)
                ((equal? return-type ''int) 'int)
                ((equal? return-type ''unsigned-int) 'unsigned-int)
                ((equal? return-type ''long) 'long)
                ((equal? return-type ''unsigned-long) 'unsigned-long)
                ((equal? return-type ''float) 'float)
                ((equal? return-type ''double) 'double)
                ((equal? return-type ''pointer) 'void*)
                ((equal? return-type ''void) 'void)
                (else return-type))))
    (if (null? argument-types)
      `(define ,scheme-name
         (foreign-procedure #f
                            ,(symbol->string (cadr c-name))
                            ()
                            ,native-return-type))
      `(define ,scheme-name
         (foreign-procedure #f
                            ,(symbol->string (cadr c-name))
                            ,native-argument-types
                            ,native-return-type)))))

(define size-of-type
  (lambda (type)
    (foreign-sizeof (type->native-type type))))

(define align-of-type
  (lambda (type)
    (foreign-alignof (type->native-type type))))

(define shared-object-load
  (lambda (path options)
    (load-shared-object path)))

(define c-bytevector-u8-set!
  (lambda (c-bytevector k byte)
    (foreign-set! 'unsigned-8 c-bytevector k byte)))

(define c-bytevector-u8-ref
  (lambda (c-bytevector k)
    (foreign-ref 'unsigned-8 c-bytevector k)))

(define c-bytevector-pointer-set!
  (lambda (c-bytevector k pointer)
    (foreign-set! 'void* c-bytevector k pointer)))

(define c-bytevector-pointer-ref
  (lambda (c-bytevector k)
    (foreign-ref 'void* c-bytevector k)))
