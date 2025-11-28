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
       (foreign-library-function shared-object
                                 (symbol->string c-name)
                                 #:return-type (type->native-type return-type)
                                 #:arg-types (map type->native-type argument-types))))))

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

#;(define pointer-set!
(lambda (pointer type offset value)
  (let ((p (pointer->bytevector pointer (+ offset 100))))
    (cond ((equal? type 'int8) (bytevector-s8-set! p offset value))
          ((equal? type 'uint8) (bytevector-u8-set! p offset value))
          ((equal? type 'int16) (bytevector-s16-set! p offset value (native-endianness)))
          ((equal? type 'uint16) (bytevector-u16-set! p offset value (native-endianness)))
          ((equal? type 'int32) (bytevector-s32-set! p offset value (native-endianness)))
          ((equal? type 'uint32) (bytevector-u32-set! p offset value (native-endianness)))
          ((equal? type 'int64) (bytevector-s64-set! p offset value (native-endianness)))
          ((equal? type 'uint64) (bytevector-u64-set! p offset value (native-endianness)))
          ((equal? type 'char) (bytevector-s8-set! p offset (char->integer value)))
          ((equal? type 'short) (bytevector-s8-set! p offset value))
          ((equal? type 'unsigned-short) (bytevector-u8-set! p offset value))
          ((equal? type 'int) (bytevector-sint-set! p offset value (native-endianness) (size-of-type type)))
          ((equal? type 'unsigned-int) (bytevector-uint-set! p offset value (native-endianness) (size-of-type type)))
          ((equal? type 'long) (bytevector-s64-set! p offset value (native-endianness)))
          ((equal? type 'unsigned-long) (bytevector-u64-set! p offset value (native-endianness)))
          ((equal? type 'float) (bytevector-ieee-single-set! p offset value (native-endianness)))
          ((equal? type 'double) (bytevector-ieee-double-set! p offset value (native-endianness)))
          ((equal? type 'pointer) (bytevector-sint-set! p offset (pointer-address value) (native-endianness) (size-of-type type)))))))

#;(define pointer-get
(lambda (pointer type offset)
  (let ((p (pointer->bytevector pointer (+ offset 100))))
    (cond ((equal? type 'int8) (bytevector-s8-ref p offset))
          ((equal? type 'uint8) (bytevector-u8-ref p offset))
          ((equal? type 'int16) (bytevector-s16-ref p offset (native-endianness)))
          ((equal? type 'uint16) (bytevector-u16-ref p offset (native-endianness)))
          ((equal? type 'int32) (bytevector-s32-ref p offset (native-endianness)))
          ((equal? type 'uint32) (bytevector-u32-ref p offset (native-endianness)))
          ((equal? type 'int64) (bytevector-s64-ref p offset (native-endianness)))
          ((equal? type 'uint64) (bytevector-u64-ref p offset (native-endianness)))
          ((equal? type 'char) (integer->char (bytevector-s8-ref p offset)))
          ((equal? type 'short) (bytevector-s8-ref p offset))
          ((equal? type 'unsigned-short) (bytevector-u8-ref p offset))
          ((equal? type 'int) (bytevector-sint-ref p offset (native-endianness) (size-of-type type)))
          ((equal? type 'unsigned-int) (bytevector-uint-ref p offset (native-endianness) (size-of-type type)))
          ((equal? type 'long) (bytevector-s64-ref p offset (native-endianness)))
          ((equal? type 'unsigned-long) (bytevector-u64-ref p offset (native-endianness)))
          ((equal? type 'float) (bytevector-ieee-single-ref p offset (native-endianness)))
          ((equal? type 'double) (bytevector-ieee-double-ref p offset (native-endianness)))
          ((equal? type 'pointer) (make-pointer (bytevector-sint-ref p offset (native-endianness) (size-of-type type))))))))
