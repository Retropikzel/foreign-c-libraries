#!r6rs
;; Akku.scm wrote this file based on "foreign/c/mit-scheme-primitives.sld"
(library
 (foreign c mit-scheme-primitives)
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
  (scheme process-context))
 (declare (usual-integrations))
 (load-option 'ffi)
 (C-include "mit-scheme-foreign-c")
 (define (hello) (puts "Hello from puts") (newline)))
