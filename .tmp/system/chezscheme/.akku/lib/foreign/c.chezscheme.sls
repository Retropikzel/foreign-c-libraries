#!r6rs
;; Akku.scm wrote this file based on "foreign/c.sld"
(library
 (foreign c)
 (export
  foreign-procedure
  c-type-size
  c-type-align
  define-c-library
  define-c-procedure
  make-c-bytevector
  c-bytevector?
  c-bytevector-u8-set!
  c-bytevector-u8-ref
  c-bytevector-pointer-set!
  c-bytevector-pointer-ref
  make-c-null
  c-null?
  c-free
  call-with-address-of
  bytevector->c-bytevector
  c-bytevector->bytevector
  string->c-utf8
  c-utf8->string
  libc-name
  native-endianness
  c-bytevector-s8-set!
  c-bytevector-s8-ref
  c-bytevector-char-set!
  c-bytevector-char-ref
  c-bytevector-uchar-set!
  c-bytevector-uchar-ref
  c-bytevector-sint-set!
  c-bytevector-sint-ref
  c-bytevector-uint-set!
  c-bytevector-uint-ref
  c-bytevector-s16-set!
  c-bytevector-s16-ref
  c-bytevector-u16-set!
  c-bytevector-u16-ref
  c-bytevector-s16-native-set!
  c-bytevector-s16-native-ref
  c-bytevector-u16-native-set!
  c-bytevector-u16-native-ref
  c-bytevector-s32-set!
  c-bytevector-s32-ref
  c-bytevector-u32-set!
  c-bytevector-u32-ref
  c-bytevector-s32-native-set!
  c-bytevector-s32-native-ref
  c-bytevector-u32-native-set!
  c-bytevector-u32-native-ref
  c-bytevector-s64-set!
  c-bytevector-s64-ref
  c-bytevector-u64-set!
  c-bytevector-u64-ref
  c-bytevector-s64-native-set!
  c-bytevector-s64-native-ref
  c-bytevector-u64-native-set!
  c-bytevector-u64-native-ref
  c-bytevector-ieee-single-native-set!
  c-bytevector-ieee-single-native-ref
  c-bytevector-ieee-single-set!
  c-bytevector-ieee-single-ref
  c-bytevector-ieee-double-set!
  c-bytevector-ieee-double-ref
  c-bytevector-ieee-double-native-set!
  c-bytevector-ieee-double-native-ref)
 (import
  (scheme base)
  (scheme write)
  (scheme char)
  (scheme file)
  (scheme process-context)
  (scheme inexact)
  (foreign c-bytevectors)
  (foreign c chez-primitives))
 (include "c/define-c-library.scm")
 (include "c/libc.scm")
 (include "c.scm"))
