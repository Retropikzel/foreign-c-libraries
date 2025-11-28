(define-library
  (foreign c)
  (import (scheme base)
          (scheme write)
          (scheme char)
          (scheme file)
          (scheme process-context)
          (scheme inexact))
  (import (foreign c-bytevectors))
  (cond-expand
    (chezscheme (import (foreign c chez-primitives))
                (export foreign-procedure))
    (chibi (import (foreign c chibi-primitives)))
    (chicken (import (foreign c chicken-primitives)
                     (chicken base)
                     (chicken foreign))
             (export foreign-declare
                     foreign-safe-lambda))
    ;(cyclone (import (foreign c cyclone-primitives)))
    ;(gambit (import (foreign c gambit-primitives)))
    (gauche (import (foreign c gauche-primitives)))
    (guile (import (foreign c guile-primitives)))
    (ikarus (import (foreign c ikarus-primitives)))
    (ironscheme (import (foreign c ironscheme-primitives)
                        ;(rename (ironscheme environment) (get-environment-variable getenv))
                        ))
    (kawa (import (foreign c kawa-primitives)))
    ;(mit-scheme (import (foreign c mit-scheme-primitives)))
    (larceny (import (foreign c larceny-primitives)))
    (mosh (import (foreign c mosh-primitives)))
    (racket (import (only (scheme base) cond-expand)
                    (foreign c racket-primitives)))
    (sagittarius (import (foreign c sagittarius-primitives)))
    (stklos (import (foreign c stklos-primitives))
            (export make-external-function
                    free-bytes))
    (ypsilon (import (foreign c ypsilon-primitives))
             (export c-function
                     bytevector-c-int8-set!
                     bytevector-c-uint8-ref)))
  (export
    ;; Primitives
    c-type-size
    c-type-align
    define-c-library
    define-c-procedure

    make-c-bytevector

    ;; Primitives
    c-bytevector?
    c-bytevector-u8-set!
    c-bytevector-u8-ref
    c-bytevector-pointer-set!
    c-bytevector-pointer-ref

    make-c-null
    c-null?
    c-free
    call-with-address-of

    bytevector->c-bytevector
    c-bytevector->bytevector

    string->c-utf8
    c-utf8->string

    libc-name

    ;; endianness
    native-endianness
    ;; c-bytevector->address
    ;; TODO c-bytevector=?
    ;; TODO c-bytevector-fill!
    ;; TODO c-bytevector-copy!
    ;; TODO c-bytevector-copy
    c-bytevector-s8-set!
    c-bytevector-s8-ref
    ;; TODO c-bytevector->u8-list
    ;; TODO u8-list->c-bytevector

    c-bytevector-char-set!
    c-bytevector-char-ref
    c-bytevector-uchar-set!
    c-bytevector-uchar-ref

    c-bytevector-sint-set!
    c-bytevector-sint-ref
    c-bytevector-uint-set!
    c-bytevector-uint-ref
    ;; TODO bytevector->uint-list
    ;; TODO bytevector->sint-list
    ;; TODO uint-list->bytevector
    ;; TODO sint-list->bytevector

    c-bytevector-s16-set!
    c-bytevector-s16-ref
    c-bytevector-u16-set!
    c-bytevector-u16-ref
    c-bytevector-s16-native-set!
    c-bytevector-s16-native-ref
    c-bytevector-u16-native-set!
    c-bytevector-u16-native-ref

    c-bytevector-s32-set!
    c-bytevector-s32-ref
    c-bytevector-u32-set!
    c-bytevector-u32-ref
    c-bytevector-s32-native-set!
    c-bytevector-s32-native-ref
    c-bytevector-u32-native-set!
    c-bytevector-u32-native-ref

    c-bytevector-s64-set!
    c-bytevector-s64-ref
    c-bytevector-u64-set!
    c-bytevector-u64-ref
    c-bytevector-s64-native-set!
    c-bytevector-s64-native-ref
    c-bytevector-u64-native-set!
    c-bytevector-u64-native-ref

    c-bytevector-ieee-single-native-set!
    c-bytevector-ieee-single-native-ref

    c-bytevector-ieee-single-set!
    c-bytevector-ieee-single-ref

    c-bytevector-ieee-double-set!
    c-bytevector-ieee-double-ref

    c-bytevector-ieee-double-native-set!
    c-bytevector-ieee-double-native-ref

    ;; TODO string->c-utf16
    ;; TODO string->c-utf32

    ;; TODO c-utf16->string
    ;; TODO c-utf32->string


    ;c-utf8-length ;; TODO ??

    ;; c-variable
    ;define-c-variable (?)
    )
  #;(cond-expand
    (gauche (begin (define implementation 'gauche)))
    (guile (begin (define implementation 'guile)))
    (racket (begin (define implementation 'racket)))
    (else (begin (define implementation 'other))))
  #;(cond-expand
    (i386 (begin (define system-arch 'i386)))
    (else (begin (define system-arch 'x86_64))))
  (cond-expand
    (windows (begin (define libc-name "ucrtbase")))
    (haiku (begin (define libc-name "root")))
    (else (begin (define libc-name "c"))))
  (cond-expand
    (chicken
      (begin
        (define-syntax define-c-library
          (syntax-rules ()
            ((_ scheme-name headers object-name options)
             (begin
               (define scheme-name #t)
               (shared-object-load headers)))))))
    (else (include "c/define-c-library.scm")))
  (cond-expand
    (chicken
      (begin
        (define-c-library libc
                          '("stdlib.h" "stdio.h" "string.h")
                          libc-name
                          '((additional-versions ("0" "6"))))

        (define-c-procedure c-malloc libc 'malloc 'pointer '(int))
        (define-c-procedure c-free libc 'free 'void '(pointer))
        (define-c-procedure c-strlen libc 'strlen 'int '(pointer))
        ;(define-c-procedure c-memset-address->pointer libc 'memset 'pointer '(uint64 uint8 int))
        (define (c-memset-address->pointer address value offset) (address->pointer address))
        ;(define-c-procedure c-memset-pointer->address libc 'memset 'uint64 '(pointer uint8 int))
        (define (c-memset-pointer->address pointer value offset) (pointer->address pointer))
        ;(define (make-c-null) (c-memset-address->pointer 0 0 0))
        (define (make-c-null) (address->pointer 0))
        (define c-null?
          (lambda (pointer)
            (if (and (not (pointer? pointer))
                     pointer)
              #f
              (or (not pointer) ; #f counts as null pointer on Chicken
                  (= (pointer->address pointer) 0)))))))
    (else (include "c/libc.scm")))
  (include "c.scm"))

