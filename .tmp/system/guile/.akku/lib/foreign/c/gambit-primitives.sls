#!r6rs
;; Akku.scm wrote this file based on "foreign/c/gambit-primitives.sld"
(library
 (foreign c gambit-primitives)
 (export
  size-of-type
  align-of-type
  shared-object-load
  define-c-procedure
  define-c-callback
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
  (only (gambit) c-declare c-lambda c-define define-macro))
 (include "gambit-primitives.scm"))
