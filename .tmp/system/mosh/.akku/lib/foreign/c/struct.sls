#!r6rs
;; Akku.scm wrote this file based on "foreign/c/struct.sld"
(library
 (foreign c struct)
 (export define-c-struct c-struct->alist)
 (import
  (scheme base)
  (scheme write)
  (scheme char)
  (scheme file)
  (scheme inexact)
  (scheme process-context))
 (include "struct.scm"))
