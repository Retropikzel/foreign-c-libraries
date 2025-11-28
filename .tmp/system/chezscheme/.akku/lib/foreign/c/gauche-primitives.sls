#!r6rs
;; Akku.scm wrote this file based on "foreign/c/gauche-primitives.sld"
(library
 (foreign c gauche-primitives)
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
  (gauche ffi))
 (include "gauche-primitives.scm"))
