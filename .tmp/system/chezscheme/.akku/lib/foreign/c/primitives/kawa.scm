(define arena (invoke-static java.lang.foreign.Arena 'global))
(define method-handle-lookup (invoke-static java.lang.invoke.MethodHandles 'lookup))
(define native-linker (invoke-static java.lang.foreign.Linker 'nativeLinker))
(define INTEGER-MAX-VALUE (static-field java.lang.Integer 'MAX_VALUE))

(define value->object
  (lambda (value type)
    (cond ((equal? type 'byte)
           (java.lang.Byte value))
          ((equal? type 'int8)
           (java.lang.Integer value))
          ((equal? type 'uint8)
           (java.lang.Integer value))
          ((equal? type 'short)
           (java.lang.Short value))
          ((equal? type 'unsigned-short)
           (java.lang.Short value))
          ((equal? type 'int)
           (java.lang.Integer value))
          ((equal? type 'unsigned-int)
           (java.lang.Integer value))
          ((equal? type 'long)
           (java.lang.Long value))
          ((equal? type 'unsigned-long)
           (java.lang.Long value))
          ((equal? type 'float)
           (java.lang.Float value))
          ((equal? type 'double)
           (java.lang.Double value))
          ((equal? type 'char)
           (java.lang.Char value))
          (else value))))

(define type->native-type
  (lambda (type)
    (cond
      ((equal? type 'int8) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 1))
      ((equal? type 'uint8) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_BYTE) 'withByteAlignment 1))
      ((equal? type 'int16) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 2))
      ((equal? type 'uint16) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 2))
      ((equal? type 'int32) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 4))
      ((equal? type 'uint32) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 4))
      ((equal? type 'int64) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 8))
      ((equal? type 'uint64) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 8))
      ((equal? type 'char) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_CHAR) 'withByteAlignment 1))
      ((equal? type 'unsigned-char) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_CHAR) 'withByteAlignment 1))
      ((equal? type 'short) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_SHORT) 'withByteAlignment 2))
      ((equal? type 'unsigned-short) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_SHORT) 'withByteAlignment 2))
      ((equal? type 'int) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 4))
      ((equal? type 'unsigned-int) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_INT) 'withByteAlignment 4))
      ((equal? type 'long) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_LONG) 'withByteAlignment 8))
      ((equal? type 'unsigned-long) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_LONG) 'withByteAlignment 8))
      ((equal? type 'float) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_FLOAT) 'withByteAlignment 4))
      ((equal? type 'double) (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_DOUBLE) 'withByteAlignment 8))
      ((equal? type 'pointer) (invoke (static-field java.lang.foreign.ValueLayout 'ADDRESS) 'withByteAlignment 8))
      ((equal? type 'void) (invoke (static-field java.lang.foreign.ValueLayout 'ADDRESS) 'withByteAlignment 1))
      ((equal? type 'callback) (invoke (static-field java.lang.foreign.ValueLayout 'ADDRESS) 'withByteAlignment 8))
      ((equal? type 'struct) (invoke (static-field java.lang.foreign.ValueLayout 'ADDRESS) 'withByteAlignment 8))
      (else #f))))

(define c-bytevector?
  (lambda (object)
    (string=? (invoke (invoke object 'getClass) 'getName)
              "jdk.internal.foreign.NativeMemorySegmentImpl")))

(define-syntax define-c-procedure
  (syntax-rules ()
    ((_ scheme-name shared-object c-name return-type argument-types)
     (define scheme-name
       (lambda vals
         (invoke (invoke (cdr (assoc 'linker shared-object))
                         'downcallHandle
                         (invoke (invoke (cdr (assoc 'lookup shared-object))
                                         'find
                                         (symbol->string c-name))
                                 'orElseThrow)
                         (if (equal? return-type 'void)
                           (apply (class-methods java.lang.foreign.FunctionDescriptor 'ofVoid)
                                  (map type->native-type argument-types))
                           (apply (class-methods java.lang.foreign.FunctionDescriptor 'of)
                                  (type->native-type return-type)
                                  (map type->native-type argument-types))))
                 'invokeWithArguments
                 (map value->object vals argument-types)))))))

(define range
  (lambda (from to)
    (letrec*
      ((looper
         (lambda (count result)
           (if (= count to)
             (append result (list count))
             (looper (+ count 1) (append result (list count)))))))
      (looper from (list)))))

(define-syntax define-c-callback
  (syntax-rules ()
    ((_ scheme-name return-type argument-types procedure)
     (define scheme-name
       (let* ((callback-procedure
                (lambda (arg1 . args)
                  (try-catch (begin (apply procedure (append (list arg1) args)))
                             (ex <java.lang.Throwable> #f))))
              (function-descriptor
                (let ((function-descriptor
                        (if (equal? return-type 'void)
                          (apply (class-methods java.lang.foreign.FunctionDescriptor 'ofVoid)
                                 (map type->native-type argument-types))
                          (apply (class-methods java.lang.foreign.FunctionDescriptor 'of)
                                 (type->native-type return-type)
                                 (map type->native-type argument-types)))))
                  (write function-descriptor)
                  (newline)
                  (write (invoke function-descriptor 'getClass))
                  (newline)
                  (write function-descriptor)
                  (newline)
                  function-descriptor))
              ;(method-type (invoke function-descriptor 'toMethodType))
              (method-type (field callback-procedure 'applyMethodType))
              (method-handle
                (let* ((method-handle (field callback-procedure 'applyToConsumerDefault)))
                  (write method-handle)
                  (newline)
                  method-handle)))
         (invoke native-linker 'upcallStub method-handle function-descriptor arena))))))

(define size-of-type
  (lambda (type)
    (let ((native-type (type->native-type type)))
      (if native-type
        (invoke native-type 'byteAlignment)
        #f))))

(define align-of-type
  (lambda (type)
    (let ((native-type (type->native-type type)))
      (if native-type
        (invoke native-type 'byteAlignment)
        #f))))

(define make-c-null
  (lambda ()
    (static-field java.lang.foreign.MemorySegment 'NULL)))

(define shared-object-load
  (lambda (path options)
    (let* ((library-file (make java.io.File path))
           (file-name (invoke library-file 'getName))
           (library-parent-folder (make java.io.File (invoke library-file 'getParent)))
           (absolute-path (string-append (invoke library-parent-folder 'getCanonicalPath)
                                         "/"
                                         file-name))
           (linker (invoke-static java.lang.foreign.Linker 'nativeLinker))
           (lookup (invoke-static java.lang.foreign.SymbolLookup
                                  'libraryLookup
                                  absolute-path
                                  arena)))
      (list (cons 'linker linker)
            (cons 'lookup lookup)))))

(define null-pointer (make-c-null))
(define c-null?
  (lambda (pointer)
    (invoke pointer 'equals null-pointer)))

(define u8-value-layout
  (invoke (static-field java.lang.foreign.ValueLayout 'JAVA_BYTE)
          'withByteAlignment
          1))

(define c-bytevector-u8-set!
  (lambda (c-bytevector k byte)
    (invoke (invoke c-bytevector 'reinterpret INTEGER-MAX-VALUE)
            'set
            u8-value-layout
            k
            byte)))

(define c-bytevector-u8-ref
  (lambda (c-bytevector k)
    (invoke (java.lang.Byte 1)
            'toUnsignedInt
            (invoke
              (invoke c-bytevector 'reinterpret INTEGER-MAX-VALUE)
              'get
              u8-value-layout
              k))))

(define pointer-value-layout
  (invoke (static-field java.lang.foreign.ValueLayout 'ADDRESS)
          'withByteAlignment
          8))

(define c-bytevector-pointer-set!
  (lambda (c-bytevector k pointer)
    (invoke (invoke c-bytevector 'reinterpret INTEGER-MAX-VALUE)
            'set
            pointer-value-layout
            k
            pointer)))

(define c-bytevector-pointer-ref
  (lambda (c-bytevector k)
    (invoke (invoke c-bytevector 'reinterpret INTEGER-MAX-VALUE)
            'get
            pointer-value-layout
            k)))

#;(define-syntax call-with-address-of-c-bytevector
          (syntax-rules ()
            ((_ input-pointer thunk)
             (let ((address-pointer (make-c-bytevector (c-type-size 'pointer))))
               (pointer-set! address-pointer 'pointer 0 input-pointer)
               (apply thunk (list address-pointer))
               (set! input-pointer (pointer-get address-pointer 'pointer 0))
               (c-free address-pointer)))))
