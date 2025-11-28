#!r6rs
;; Akku.scm wrote this file based on "foreign/c/guile-primitives.sld"
(library
 (foreign c guile-primitives)
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
  implementation
  os
  arch
  libc-name)
 (import
  (scheme base)
  (scheme write)
  (scheme char)
  (scheme file)
  (scheme inexact)
  (scheme process-context)
  (system foreign)
  (system foreign-library)
  (foreign c-bytevectors))
 (include "guile-primitives.scm"))
