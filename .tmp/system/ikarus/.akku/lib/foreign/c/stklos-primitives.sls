#!r6rs
;; Akku.scm wrote this file based on "foreign/c/stklos-primitives.sld"
(library
 (foreign c stklos-primitives)
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
  get-environment-variable
  file-exists?
  make-external-function
  void?
  free-bytes)
 (import
  (scheme base)
  (scheme write)
  (scheme char)
  (scheme file)
  (scheme inexact)
  (scheme process-context)
  (only (stklos)
        %make-callback
        make-external-function
        allocate-bytes
        free-bytes
        cpointer?
        cpointer-null?
        cpointer-data
        cpointer-data-set!
        cpointer-set-abs!
        cpointer-ref-abs
        c-size-of
        void?)
  (foreign c-bytevectors))
 (include "stklos-primitives.scm"))
