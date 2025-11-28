(define-library
  (foreign c racket-primitives)
  (import (scheme base)
          (scheme write)
          (scheme char)
          (scheme file)
          (scheme inexact)
          (scheme process-context)
          (only (racket base)
                system-type
                system-big-endian?)
          (ffi winapi)
          (compatibility mlist)
          (ffi unsafe)
          (ffi vector))
  (export size-of-type
          align-of-type
          shared-object-load
          define-c-procedure
          c-bytevector?
          c-bytevector-u8-ref
          c-bytevector-u8-set!
          c-bytevector-pointer-ref
          c-bytevector-pointer-set!)
  (include "racket-primitives.scm"))
