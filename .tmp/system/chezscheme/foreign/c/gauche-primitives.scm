(define shared-object-load
  (lambda (path options)
    (if (null? options)
      (open-shared-library path)
      (open-shared-library path (cadr (assoc 'additional-versions options))))))

(define type->native-type
  (lambda (type)
    (cond ((equal? type 'int8) 'int8)
          ((equal? type 'uint8) 'uint8)
          ((equal? type 'int16) 'int16)
          ((equal? type 'uint16) 'uint16)
          ((equal? type 'int32) 'int32)
          ((equal? type 'uint32) 'uint32)
          ((equal? type 'int64) 'int64)
          ((equal? type 'uint64) 'uint64)
          ((equal? type 'char) 'char)
          ((equal? type 'unsigned-char) 'char)
          ((equal? type 'short) 'short)
          ((equal? type 'unsigned-short) 'unsigned-short)
          ((equal? type 'int) 'int)
          ((equal? type 'unsigned-int) 'unsigned-int)
          ((equal? type 'long) 'long)
          ((equal? type 'unsigned-long) 'unsigned-long)
          ((equal? type 'float) 'float)
          ((equal? type 'double) 'double)
          ((equal? type 'pointer) 'pointer)
          ((equal? type 'void) 'pointer)
          ((equal? type 'callback) 'callback)
          (else #f))))

(define-syntax define-c-procedure
  (syntax-rules ()
    ((_ scheme-name shared-object c-name return-type argument-types)
     (define scheme-name
       (make-c-function shared-object
                        (type->native-type return-type)
                        c-name
                        (map type->native-type argument-types))))))

(define c-bytevector?
  (lambda (object)
    (pointer? object)))

(define c-bytevector-u8-set! pointer-set-c-uint8!)
(define c-bytevector-u8-ref pointer-ref-c-uint8)
(define c-bytevector-pointer-set! pointer-set-c-pointer!)
(define c-bytevector-pointer-ref pointer-ref-c-pointer)
