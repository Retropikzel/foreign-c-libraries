(define-library
  (foreign c chibi-primitives)
  (import (scheme base)
          (scheme write)
          (scheme char)
          (scheme file)
          (scheme process-context)
          (chibi ast)
          (scheme inexact)
          (except (chibi) c-null?)
          (foreign c-bytevectors))
  (export size-of-type
          align-of-type
          shared-object-load
          define-c-procedure
          c-bytevector?
          c-bytevector-u8-ref
          c-bytevector-u8-set!
          c-bytevector-pointer-ref
          c-bytevector-pointer-set!)
  (include-shared "chibi-primitives")
  (include "chibi-primitives.scm"))
