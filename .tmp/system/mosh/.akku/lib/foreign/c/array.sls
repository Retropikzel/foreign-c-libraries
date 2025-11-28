#!r6rs
;; Akku.scm wrote this file based on "foreign/c/array.sld"
(library
 (foreign c array)
 (export make-c-array c-array-ref c-array-set! list->c-array c-array->list)
 (import
  (scheme base)
  (scheme write)
  (scheme char)
  (scheme file)
  (scheme inexact)
  (scheme process-context))
 (include "array.scm"))
