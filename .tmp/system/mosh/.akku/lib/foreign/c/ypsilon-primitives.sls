#!r6rs
;; Akku.scm wrote this file based on "foreign/c/ypsilon-primitives.sld"
(library
 (foreign c ypsilon-primitives)
 (export
  size-of-type
  align-of-type
  shared-object-load
  define-c-procedure
  c-bytevector?
  c-bytevector-u8-ref
  c-bytevector-u8-set!
  c-bytevector-pointer-ref
  c-bytevector-pointer-set!
  c-function
  bytevector-c-int8-set!
  bytevector-c-uint8-ref)
 (import
  (scheme base)
  (scheme write)
  (scheme char)
  (scheme file)
  (scheme inexact)
  (scheme process-context)
  (ypsilon c-ffi)
  (ypsilon c-types)
  (only (core)
        define-macro
        syntax-case
        bytevector-c-int8-set!
        bytevector-c-uint8-ref))
 (include "ypsilon-primitives.scm"))
