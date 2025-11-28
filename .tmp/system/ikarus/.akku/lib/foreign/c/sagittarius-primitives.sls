#!r6rs
;; Akku.scm wrote this file based on "foreign/c/sagittarius-primitives.sld"
(library
 (foreign c sagittarius-primitives)
 (export
  size-of-type
  align-of-type
  shared-object-load
  define-c-procedure
  c-bytevector?
  c-bytevector-u8-ref
  c-bytevector-u8-set!
  c-bytevector-pointer-ref
  c-bytevector-pointer-set!)
 (import
  (scheme base)
  (scheme write)
  (scheme char)
  (scheme file)
  (scheme inexact)
  (scheme process-context)
  (except (sagittarius ffi) c-free c-malloc define-c-struct)
  (sagittarius))
 (include "sagittarius-primitives.scm"))
