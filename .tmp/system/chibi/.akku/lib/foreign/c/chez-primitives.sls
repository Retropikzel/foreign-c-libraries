#!r6rs
;; Akku.scm wrote this file based on "foreign/c/chez-primitives.sld"
(library
 (foreign c chez-primitives)
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
  foreign-procedure
  type->native-type)
 (import (chezscheme))
 (include "chez-primitives.scm"))
