(define-library
  (foreign c ikarus-primitives)
  (export size-of-type
          align-of-type
          shared-object-load
          define-c-procedure
          c-bytevector?
          c-bytevector-u8-ref
          c-bytevector-u8-set!
          c-bytevector-pointer-ref
          c-bytevector-pointer-set!)
  (import (rnrs base)
          (rnrs lists)
          (rnrs control)
          (rnrs files)
          (rnrs io simple)
          (rnrs programs)
          (only (rnrs bytevectors)
                make-bytevector
                bytevector-length
                utf8->string
                string->utf8
                bytevector-u8-ref
                bytevector-u8-set!)
          (only (rnrs r5rs)
                remainder
                quotient)
          (ikarus include)
          (ikarus foreign))
  (begin
    (define size-of-type
      (lambda (type)
        (cond ((eq? type 'int8) 1)
              ((eq? type 'uint8) 1)
              ((eq? type 'int16) 2)
              ((eq? type 'uint16) 2)
              ((eq? type 'int32) 4)
              ((eq? type 'uint32) 4)
              ((eq? type 'int64) 8)
              ((eq? type 'uint64) 8)
              ((eq? type 'char) 1)
              ((eq? type 'unsigned-char) 1)
              ((eq? type 'short) 2)
              ((eq? type 'unsigned-short) 2)
              ((eq? type 'int) 4)
              ((eq? type 'unsigned-int) 4)
              ((eq? type 'long) 8)
              ((eq? type 'unsigned-long) 8)
              ((eq? type 'float) 4)
              ((eq? type 'double) 8)
              ((eq? type 'pointer) 8)
              ((eq? type 'void) 0)
              (else #f))))

    ;; FIXME
    (define align-of-type size-of-type)

    (define (type->native-type type)
      (cond ((equal? type 'int8) 'signed-char)
            ((equal? type 'uint8) 'unsigned-char)
            ((equal? type 'int16) 'signed-short)
            ((equal? type 'uint16) 'unsigned-short)
            ((equal? type 'int32) 'signed-int)
            ((equal? type 'uint32) 'unsigned-int)
            ((equal? type 'int64) 'signed-long)
            ((equal? type 'uint64) 'unsigned-long)
            ((equal? type 'char) 'signed-char)
            ((equal? type 'unsigned-char) 'unsigned-char)
            ((equal? type 'short) 'signed-short)
            ((equal? type 'unsigned-short) 'unsigned-short)
            ((equal? type 'int) 'signed-int)
            ((equal? type 'unsigned-int) 'unsigned-int)
            ((equal? type 'long) 'signed-long)
            ((equal? type 'unsigned-long) 'unsigned-long)
            ((equal? type 'float) 'float)
            ((equal? type 'double) 'double)
            ((equal? type 'pointer) 'pointer)
            ((equal? type 'void) 'void)
            (error "Unsupported type: " type)))

    (define c-bytevector?
      (lambda (object)
        (pointer? object)))

    (define-syntax define-c-procedure
      (syntax-rules ()
        ((_ scheme-name shared-object c-name return-type argument-types)
         (define scheme-name
           ((make-c-callout (type->native-type return-type)
                            (map type->native-type argument-types))
            (dlsym shared-object (symbol->string c-name)))))))

    (define shared-object-load
      (lambda (path options)
        (dlopen path)))

    (define c-bytevector-u8-set!
      (lambda (c-bytevector k byte)
        (pointer-set-c-char! c-bytevector k byte)))

    (define c-bytevector-u8-ref
      (lambda (c-bytevector k)
        (pointer-ref-c-unsigned-char c-bytevector k)))

    (define c-bytevector-pointer-set!
      (lambda (c-bytevector k pointer)
        (pointer-set-c-pointer! c-bytevector k pointer)))

    (define c-bytevector-pointer-ref
      (lambda (c-bytevector k)
        (pointer-ref-c-pointer c-bytevector k)))))
