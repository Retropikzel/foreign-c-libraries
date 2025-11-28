(define os 'unix)
(define implementation 'guile)
(define arch 'x86_64)
(define libc-name "c")

(define type->native-type
  (lambda (type)
    (cond ((equal? type 'int8) int8)
          ((equal? type 'uint8) uint8)
          ((equal? type 'int16) int16)
          ((equal? type 'uint16) uint16)
          ((equal? type 'int32) int32)
          ((equal? type 'uint32) uint32)
          ((equal? type 'int64) int64)
          ((equal? type 'uint64) uint64)
          ((equal? type 'char) int8)
          ((equal? type 'unsigned-char) uint8)
          ((equal? type 'short) short)
          ((equal? type 'unsigned-short) unsigned-short)
          ((equal? type 'int) int)
          ((equal? type 'unsigned-int) unsigned-int)
          ((equal? type 'long) long)
          ((equal? type 'unsigned-long) unsigned-long)
          ((equal? type 'float) float)
          ((equal? type 'double) double)
          ((equal? type 'pointer) '*)
          ((equal? type 'void) void)
          ((equal? type 'callback) '*)
          (else #f))))

(define c-bytevector?
  (lambda (object)
    (pointer? object)))

(define-syntax define-c-procedure
  (syntax-rules ()
    ((_ scheme-name shared-object c-name return-type argument-types)
     (define scheme-name
       (pointer->procedure (type->native-type return-type)
                           (foreign-library-pointer shared-object
                                                    (symbol->string c-name))
                           (map type->native-type argument-types))))))

(define-syntax define-c-callback
  (syntax-rules ()
    ((_ scheme-name return-type argument-types procedure)
     (define scheme-name
       (procedure->pointer (type->native-type return-type)
                           procedure
                           (map type->native-type argument-types))))))

(define size-of-type
  (lambda (type)
    (let ((native-type (type->native-type type)))
      (cond ((equal? native-type void) 0)
            (native-type (sizeof native-type))
            (else #f)))))

(define align-of-type
  (lambda (type)
    (let ((native-type (type->native-type type)))
      (cond ((equal? native-type void) 0)
            (native-type (alignof native-type))
            (else #f)))))

(define shared-object-load
  (lambda (path options)
    (load-foreign-library path)))

(define c-bytevector-u8-set!
  (lambda (c-bytevector k byte)
    (let ((p (pointer->bytevector c-bytevector (+ k 100))))
      (bytevector-u8-set! p k byte))))

(define c-bytevector-u8-ref
  (lambda (c-bytevector k)
    (let ((p (pointer->bytevector c-bytevector (+ k 100))))
      (bytevector-u8-ref p k))))

(define c-bytevector-pointer-set!
  (lambda (c-bytevector k pointer)
    (c-bytevector-uint-set! c-bytevector
                            k
                            (pointer-address pointer)
                            (native-endianness)
                            (size-of-type 'pointer))))

(define c-bytevector-pointer-ref
  (lambda (c-bytevector k)
    (make-pointer (c-bytevector-uint-ref c-bytevector
                                         k
                                         (native-endianness)
                                         (size-of-type 'pointer)))))

(c-bytevectors-init #f c-bytevector-u8-set! c-bytevector-u8-ref)
