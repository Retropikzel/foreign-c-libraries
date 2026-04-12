(define-c-library libc '("stdlib.h") #f '())
(define-c-procedure c-perror libc 'perror 'void '(pointer))

(define-c-library c-gi
                  '("girepository/girepository.h")
                  "girepository-2.0"
                  '((additional-versions ("0"))))



(define-c-procedure c-gi-repository-new c-gi 'gi_repository_new 'pointer '())
(define-c-procedure c-gi-repository-require c-gi 'gi_repository_require 'pointer '(pointer pointer pointer int pointer))
(define-c-procedure c-gi-repository-find-by-name c-gi 'gi_repository_find_by_name 'pointer '(pointer pointer pointer))
(define-c-procedure c-gi-repository-c-prefix c-gi 'gi_repository_get_c_prefix 'pointer '(pointer pointer))
(define-c-procedure c-gi-repository-get-loaded-namespaces c-gi 'gi_repository_get_loaded_namespaces 'pointer '(pointer pointer))

(define-c-procedure c-gi-base-info-get-name c-gi 'gi_base_info_get_name 'pointer '(pointer))
(define-c-procedure c-gi-base-info-get-namespace c-gi 'gi_base_info_get_namespace 'pointer '(pointer))
(define-c-procedure c-gi-base-info-get-typelib c-gi 'gi_base_info_get_typelib 'pointer '(pointer))
(define-c-procedure c-gi-base-info-get-attribute c-gi 'gi_base_info_get_attribute 'pointer '(pointer pointer))
(define-c-procedure c-gi-base-info-get-namespace c-gi 'gi_base_info_get_namespace 'pointer '(pointer))

(define-c-procedure c-gi-function-info-invoke c-gi 'gi_function_info_invoke 'int '(pointer pointer int pointer int pointer pointer))

(define-c-procedure c-gi-callable-info-get-return-type c-gi 'gi_callable_info_get_return_type 'pointer '(pointer))
(define-c-procedure c-gi-callable-info-get-n-args c-gi 'gi_callable_info_get_n_args 'uint '(pointer))
(define-c-procedure c-gi-callable-info-get-arg c-gi 'gi_callable_info_get_arg 'pointer '(pointer uint))

(define-c-procedure c-gi-arg-info-get-type-info c-gi 'gi_arg_info_get_type_info 'pointer '(pointer))

(define-c-procedure c-gi-type-info-get-tag c-gi 'gi_type_info_get_tag 'uint '(pointer))
(define-c-procedure c-gi-type-info-get-interface c-gi 'gi_type_info_get_interface 'pointer '(pointer))

(define-c-procedure c-gi-struct-info-find-method c-gi 'gi_struct_info_find_method 'pointer '(pointer pointer))

(define-c-procedure c-gi-object-info-find-method c-gi 'gi_object_info_find_method 'pointer '(pointer pointer))
(define-c-procedure c-gi-object-info-find-signal c-gi 'gi_object_info_find_signal 'pointer '(pointer pointer))

(define-c-struct-type gerror '((domain u32) (code int) (message pointer)))

(define GI-TYPE-TAG-VOID 0)
(define GI-TYPE-TAG-BOOLEAN 1)
(define GI-TYPE-TAG-INT8 2)
(define GI-TYPE-TAG-UINT8 3)
(define GI-TYPE-TAG-INT16 4)
(define GI-TYPE-TAG-UINT16 5)
(define GI-TYPE-TAG-INT32 6)
(define GI-TYPE-TAG-UINT32 7)
(define GI-TYPE-TAG-INT64 8)
(define GI-TYPE-TAG-UINT64 9)
(define GI-TYPE-TAG-FLOAT 10)
(define GI-TYPE-TAG-DOUBLE 11)
(define GI-TYPE-TAG-GTYPE 12)
(define GI-TYPE-TAG-UTF8 13)
(define GI-TYPE-TAG-FILENAME 14)
(define GI-TYPE-TAG-ARRAY 15)
(define GI-TYPE-TAG-INTERFACE 16)
(define GI-TYPE-TAG-GLIST 17)
(define GI-TYPE-TAG-GSLIST 18)
(define GI-TYPE-TAG-GHASH 19)
(define GI-TYPE-TAG-ERROR 20)
(define GI-TYPE-TAG-UNICHAR 21)

(define (gi-type->foreign-c-type type-info)
  (let* ((tag (c-gi-type-info-get-tag type-info))
        (result (cond ((= tag GI-TYPE-TAG-VOID)
                       ;; FIXME
                       'callback)
                      ((= tag GI-TYPE-TAG-BOOLEAN) 'int)
                      ((= tag GI-TYPE-TAG-INT8) 'i8)
                      ((= tag GI-TYPE-TAG-UINT8) 'u8)
                      ((= tag GI-TYPE-TAG-INT16) 'i16)
                      ((= tag GI-TYPE-TAG-UINT16) 'u16)
                      ((= tag GI-TYPE-TAG-INT32) 'i32)
                      ((= tag GI-TYPE-TAG-UINT32) 'u32)
                      ((= tag GI-TYPE-TAG-INT64) 'i64)
                      ((= tag GI-TYPE-TAG-UINT64) 'u64)
                      ((= tag GI-TYPE-TAG-FLOAT) 'float)
                      ((= tag GI-TYPE-TAG-DOUBLE) 'double)
                      ((= tag GI-TYPE-TAG-GTYPE) 'int)
                      ((= tag GI-TYPE-TAG-UTF8) 'pointer)
                      ((= tag GI-TYPE-TAG-FILENAME) 'pointer)
                      ((= tag GI-TYPE-TAG-ARRAY) 'pointer)
                      ((= tag GI-TYPE-TAG-INTERFACE)
                       ;(display "HERE: interface name ")
                       ;(write (c-bytevector->string (c-gi-base-info-get-name (c-gi-type-info-get-interface type-info))))
                       ;(newline)
                       ;; FIXME Read type from type-info somehow
                       (cond ((or
                              (string=? (c-bytevector->string (c-gi-base-info-get-name (c-gi-type-info-get-interface type-info))) "ApplicationFlags")
                              (string=? (c-bytevector->string (c-gi-base-info-get-name (c-gi-type-info-get-interface type-info))) "WindowType"))
                              'int)
                             (else 'pointer)))
                      ((= tag GI-TYPE-TAG-GLIST) 'pointer)
                      ((= tag GI-TYPE-TAG-GSLIST) 'pointer)
                      ((= tag GI-TYPE-TAG-GHASH) 'pointer)
                      ((= tag GI-TYPE-TAG-ERROR) 'pointer)
                      ((= tag GI-TYPE-TAG-UNICHAR) 'int)
                      (else (error "gi-type->foreign-c-type: Unknown gi-type"
                                   (c-bytevector->string (c-gi-base-info-get-name (c-gi-type-info-get-interface type-info))))))))
    result))

(define-record-type <gi-repository>
  (make-gi-repository name cbv)
  gi-repository?
  (name gi-repository-name)
  (cbv gi-repository-cbv))

(define (gi-repository name version)
  (let ((repository (c-gi-repository-new))
        (err (c-bytevector-null)))
    (call-with-address-of
      err
      (lambda (err-address)
        (c-gi-repository-require repository
                                 (string->c-bytevector name)
                                 (string->c-bytevector version)
                                 0
                                 err-address)))
    (when (not (c-bytevector-null? err))
      (let* ((error-list (c-bytevector->list err gerror))
             (msg (c-bytevector->string (cdr (assoc 'message error-list)))))
        (c-bytevector-free (cdr (assoc 'message error-list)))
        (c-bytevector-free repository)
        (error (string-append "load-gi-repository: " msg)
               (car error-list)
               (cadr error-list))))
    (make-gi-repository name repository)))

(define (gi-repository-info repository)
  (let*
    ((cbv (gi-repository-cbv repository))
     (c-prefix (c-bytevector->string
                 (c-gi-repository-c-prefix cbv
                                           (string->c-bytevector
                                             (gi-repository-name repository)))))
     (loaded-namespaces
       (letrec* ((count-cbv (make-c-bytevector (c-type-size 'int)))
                 (namespaces (c-gi-repository-get-loaded-namespaces cbv count-cbv))
                 (count (c-bytevector-ref count-cbv 'int 0))
                 (looper
                   (lambda (index result)
                     (if (= index count)
                       result
                       (looper (+ index 1)
                               (append result
                                       (list
                                         (c-bytevector->string (c-bytevector-ref namespaces
                                                                                 'pointer
                                                                                 (* (c-type-size 'pointer) index))))))))))
         (looper 0 '())
         ))
     )
    `((c-prefix . ,c-prefix)
      (loaded-namespaces . ,loaded-namespaces)
      )))

(define (gi-function-info repository function-name)
  (let ((info (c-gi-repository-find-by-name
                (gi-repository-cbv repository)
                (string->c-bytevector (gi-repository-name repository))
                (string->c-bytevector function-name))))
    (if (c-bytevector-null? info)
      #f
      (letrec*
        ((return-info (c-gi-callable-info-get-return-type info))
         (return-type (gi-type->foreign-c-type return-info))
         (argument-count (c-gi-callable-info-get-n-args info))
         (argument-types-loop
           (lambda (index result)
             (if (= index argument-count)
               result
               (argument-types-loop
                 (+ index 1)
                 (append
                   result
                   (list
                     (let* ((arg-info (c-gi-callable-info-get-arg info index))
                            (type-info (c-gi-arg-info-get-type-info arg-info))
                            (type (gi-type->foreign-c-type type-info)))
                       `((type . ,type)
                         (index . ,index)))))))))
         (argument-types (argument-types-loop 0 '())))
        `((namespace . ,(gi-repository-name repository))
          (function-name . ,function-name)
          (return-type . ,return-type)
          (argument-count . ,argument-count)
          (argument-types . ,argument-types)
          (info-cbv . ,info))))))

(define (gi-invoke repository name . args)
  (when (not (gi-repository? repository))
    (error "gi-invoke: repository argument must be gi-repository" repository))
  (when (not (string? name))
    (error "gi-invoke: name argument must be string" name))
  (letrec*
    ((function-info
       (let ((function-info
               (c-gi-repository-find-by-name
                 (gi-repository-cbv repository)
                 (string->c-bytevector (gi-repository-name repository))
                 (string->c-bytevector name))))
         (when (c-bytevector-null? function-info)
           (error "gi-invoke: Repository has not function"
                  (gi-repository-name repository)
                  name))
         function-info))
     (function-return-info (c-gi-callable-info-get-return-type function-info))
     (return-type (gi-type->foreign-c-type function-return-info))
     (n-args (let ((n-args (c-gi-callable-info-get-n-args function-info)))
               (when (not (= n-args (length args)))
                 (error
                   (string-append "gi-invoke: Argument count mismatch, got "
                                  (number->string (length args))
                                  ", wanted "
                                  (number->string n-args))
                   ;(gi-object-namespace object)
                   ;(gi-object-name object)
                   name))
               n-args))
     (arg-info-looper
       (lambda (index result)
         (if (or (= index n-args)
                 (= index (length args)))
           result
           (arg-info-looper
             (+ index 1)
             (append
               result
               (list
                 (let* ((arg-info (c-gi-callable-info-get-arg function-info index))
                        (type-info (c-gi-arg-info-get-type-info arg-info))
                        (type (gi-type->foreign-c-type type-info)))
                   (cons type (list-ref args index)))))))))
     (arg-info (arg-info-looper 0 '()))
     (arg-cbv (make-c-bytevector 1024))
     (arg-cbv-offset 0)
     (invoke-error (c-bytevector-null))
     (return-value (make-c-bytevector 1024)))
    (for-each
      (lambda (arg)
        (c-bytevector-set! arg-cbv
                           (car arg)
                           arg-cbv-offset
                           (if (string? (cdr arg))
                             (string->c-bytevector (cdr arg))
                             (cdr arg)))
        (set! arg-cbv-offset (+ arg-cbv-offset (c-type-size (car arg)))))
      arg-info)
    (c-gi-function-info-invoke function-info
                               arg-cbv
                               n-args
                               (c-bytevector-null)
                               0
                               return-value
                               invoke-error)
    (when (not (symbol=? return-type 'void))
      (c-bytevector-ref return-value return-type 0))))

(define (gi-struct repository namespace name)
  (let ((base-info
          (c-gi-repository-find-by-name (gi-repository-cbv repository)
                                        (string->c-bytevector namespace)
                                        (string->c-bytevector name))))
    (when (c-bytevector-null? base-info)
      (c-perror (string->c-bytevector "(C perror) gi-object"))
      (error "gi-object: ERROR" namespace name base-info))
    base-info))

(define (gi-struct-method-info struct method-name)
  (let ((info (c-gi-struct-info-find-method struct (string->c-bytevector method-name))))
    (if (c-bytevector-null? info)
      #f
      (letrec*
        ((return-info (c-gi-callable-info-get-return-type info))
         (return-type (gi-type->foreign-c-type return-info))
         (argument-count (c-gi-callable-info-get-n-args info))
         (argument-types-loop
           (lambda (index result)
             (if (= index argument-count)
               result
               (argument-types-loop
                 (+ index 1)
                 (append
                   result
                   (list
                     (let* ((arg-info (c-gi-callable-info-get-arg info index))
                            (type-info (c-gi-arg-info-get-type-info arg-info))
                            (type (gi-type->foreign-c-type type-info)))
                       `((type . ,type)
                         (index . ,index)))))))))
         (argument-types (argument-types-loop 0 '())))
        `((namespace . ,(gi-info-namespace struct))
          (struct-name . ,(gi-info-name struct))
          (method-name . ,method-name)
          (return-type . ,return-type)
          (argument-count . ,argument-count)
          (argument-types . ,argument-types)
          (info-cbv . ,info))))))

(define (gi-struct-invoke struct method-name . args)
  (let ((method-info (gi-struct-method-info struct method-name)))
    (when (not method-info)
      (error "gi-struct-invoke: Struct has no method" struct method-name))
    (when (not (= (cdr (assoc 'argument-count method-info)) (length args)))
      (error
        (string-append "gi-struct-invoke: Argument count mismatch, got "
                       (number->string (length args))
                       ", wanted "
                       (number->string (cdr (assoc 'argument-count method-info))))
        (gi-struct-namespace struct)
        (gi-struct-name struct)
        method-name))
    (let
      ((info-cbv (cdr (assoc 'info-cbv method-info)))
       (arg-cbv (make-c-bytevector 1024))
       (arg-cbv-offset 0)
       (invoke-error (c-bytevector-null))
       (return-value (make-c-bytevector 1024)))
      (for-each
        (lambda (arg)
          (let ((value (list-ref args (cdr (assoc 'index arg)))))
            (c-bytevector-set! arg-cbv
                               (cdr (assoc 'type arg))
                               arg-cbv-offset
                               (if (string? value)
                                 (string->c-bytevector value)
                                 value))
            (set! arg-cbv-offset (+ arg-cbv-offset (c-type-size (cdr (assoc 'type arg)))))))
        (cdr (assoc 'argument-types method-info)))
      (c-gi-function-info-invoke info-cbv
                                 arg-cbv
                                 (cdr (assoc 'argument-count method-info))
                                 (c-bytevector-null)
                                 0
                                 return-value
                                 invoke-error)
      (if (not (symbol=? (cdr (assoc 'return-type method-info)) 'void))
        (c-bytevector-ref return-value
                          (cdr (assoc 'return-type method-info))
                          0)))))

(define (gi-object repository namespace name)
  (let ((base-info
          (c-gi-repository-find-by-name (gi-repository-cbv repository)
                                        (string->c-bytevector namespace)
                                        (string->c-bytevector name))))
    (when (c-bytevector-null? base-info)
      (c-perror (string->c-bytevector "(C perror) gi-object"))
      (error "gi-object: ERROR" namespace name base-info))
    base-info))

(define (gi-info-namespace info)
  (c-bytevector->string (c-gi-base-info-get-namespace info)))
(define gi-object-namespace gi-info-namespace)
(define gi-struct-namespace gi-info-namespace)

(define (gi-info-name info)
  (c-bytevector->string (c-gi-base-info-get-name info)))
(define gi-object-name gi-info-name)
(define gi-struct-name gi-info-name)

(define (gi-object-method-info object method-name)
  (let ((info (c-gi-object-info-find-method object (string->c-bytevector method-name))))
    (if (c-bytevector-null? info)
      #f
      (letrec*
        ((return-info (c-gi-callable-info-get-return-type info))
         (return-type (gi-type->foreign-c-type return-info))
         (argument-count (c-gi-callable-info-get-n-args info))
         (argument-types-loop
           (lambda (index result)
             (if (= index argument-count)
               result
               (argument-types-loop
                 (+ index 1)
                 (append
                   result
                   (list
                     (let* ((arg-info (c-gi-callable-info-get-arg info index))
                            (type-info (c-gi-arg-info-get-type-info arg-info))
                            (type (gi-type->foreign-c-type type-info)))
                       `((type . ,type)
                         (index . ,index)))))))))
         (argument-types (argument-types-loop 0 '())))
        `((namespace . ,(gi-info-namespace object))
          (object-name . ,(gi-info-name object))
          (method-name . ,method-name)
          (return-type . ,return-type)
          (argument-count . ,argument-count)
          (argument-types . ,argument-types)
          (info-cbv . ,info))))))

(define (gi-object-invoke object method-name . args)
  (let ((method-info (gi-object-method-info object method-name)))
    (when (not method-info)
      (error "gi-object-invoke: Object has no method" object method-name))
    (when (not (= (cdr (assoc 'argument-count method-info)) (length args)))
      (error
        (string-append "gi-object-invoke: Argument count mismatch, got "
                       (number->string (length args))
                       ", wanted "
                       (number->string (cdr (assoc 'argument-count method-info))))
        (gi-object-namespace object)
        (gi-object-name object)
        method-name))
    (let
      ((info-cbv (cdr (assoc 'info-cbv method-info)))
       (arg-cbv (make-c-bytevector 1024))
       (arg-cbv-offset 0)
       (invoke-error (c-bytevector-null))
       (return-value (make-c-bytevector 1024)))
      (for-each
        (lambda (arg)
          (display "HERE: arg ")
          (write arg)
          (newline)
          (let ((value (list-ref args (cdr (assoc 'index arg)))))
            (c-bytevector-set! arg-cbv
                               (cdr (assoc 'type arg))
                               arg-cbv-offset
                               (if (string? value)
                                 (string->c-bytevector value)
                                 value))
            (set! arg-cbv-offset (+ arg-cbv-offset (c-type-size (cdr (assoc 'type arg)))))))
        (cdr (assoc 'argument-types method-info)))
      (c-gi-function-info-invoke info-cbv
                                 arg-cbv
                                 (cdr (assoc 'argument-count method-info))
                                 (c-bytevector-null)
                                 0
                                 return-value
                                 invoke-error)
      (if (not (symbol=? (cdr (assoc 'return-type method-info)) 'void))
        (c-bytevector-ref return-value
                          (cdr (assoc 'return-type method-info))
                          0)))))
