(define c-type-size
  (lambda (type)
    (size-of-type type)))

(define c-type-align
  (lambda (type)
    (align-of-type type)))

(define make-c-bytevector
  (lambda (k . byte)
    (if (null? byte)
      (c-malloc k)
      (bytevector->c-bytevector (make-bytevector k (car byte))))))

(define c-bytevector
  (lambda bytes
    (bytevector->c-bytevector
      (apply (lambda (b) (make-bytevector 1 b)) bytes))))

(define bytevector->c-bytevector
  (lambda (bytes)
    (letrec* ((bytes-length (bytevector-length bytes))
              (pointer (make-c-bytevector bytes-length))
              (looper (lambda (index)
                        (when (< index bytes-length)
                          (c-bytevector-u8-set! pointer
                                                index
                                                (bytevector-u8-ref bytes index))
                          (looper (+ index 1))))))
      (looper 0)
      pointer)))

(define c-bytevector->bytevector
  (lambda (pointer size)
    (letrec* ((bytes (make-bytevector size))
              (looper (lambda (index)
                        (let ((byte (c-bytevector-u8-ref pointer index)))
                          (if (= index size)
                            bytes
                            (begin
                              (bytevector-u8-set! bytes index byte)
                              (looper (+ index 1))))))))
      (looper 0))))

(define c-string-length
  (lambda (bytevector-var)
    (c-strlen bytevector-var)))

(define c-utf8->string
  (lambda (c-bytevector)
    (when (c-null? c-bytevector)
      (error "Can not turn null pointer into string" c-bytevector))
    (let ((size (c-strlen c-bytevector)))
      (utf8->string (c-bytevector->bytevector c-bytevector size)))))

(define string->c-utf8
  (lambda (string-var)
    (bytevector->c-bytevector
      (string->utf8
        (string-append string-var (string (integer->char 0)))))))

(define c-bytevector->address
  (lambda (c-bytevector)
    (c-memset-pointer->address c-bytevector 0 0)))

(define address->c-bytevector
  (lambda (address)
    (c-memset-address->pointer address 0 0)))

(define-syntax call-with-address-of
  (syntax-rules ()
    ((_ input-pointer thunk)
     (let ((address-pointer (make-c-bytevector (c-type-size 'pointer))))
       (c-bytevector-pointer-set! address-pointer 0 input-pointer)
       (let ((result (apply thunk (list address-pointer))))
         (set! input-pointer (c-bytevector-pointer-ref address-pointer 0))
         (c-free address-pointer)
         result)))))

(c-bytevectors-init make-c-bytevector c-bytevector-u8-set! c-bytevector-u8-ref)
