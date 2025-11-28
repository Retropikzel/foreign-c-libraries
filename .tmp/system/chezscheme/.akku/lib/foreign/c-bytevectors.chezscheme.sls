#!r6rs
;; Akku.scm wrote this file based on "foreign/c-bytevectors.sld"
;;; Copyright 2025 Retropikzel
;;;
;;; Permission to copy this software, in whole or in part, to use this
;;; software for any lawful purpose, and to redistribute this software
;;; is granted subject to the restriction that all copies made of this
;;; software must include this copyright and permission notice in full.
;;;
;;; This is R6RS c-Bytevectors library, modified to work with C pointers.
;;; Mostly just by adding c- prefix to each word "bytevector".
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copyright 2015 William D Clinger.
;;;
;;; Permission to copy this software, in whole or in part, to use this
;;; software for any lawful purpose, and to redistribute this software
;;; is granted subject to the restriction that all copies made of this
;;; software must include this copyright and permission notice in full.
;;;
;;; I also request that you send me a copy of any improvements that you
;;; make to this software so that they may be incorporated within it to
;;; the benefit of the Scheme community.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; This R7RS-portable implementation of (rnrs bytevectors) is
;;; mostly derived from Larceny's src/Lib/Common/bytevector.sch.
;;;
;;; The R6RS requires implementations to select a native endianness.
;;; That choice is arbitrary, intended to affect performance but not
;;; behavior.  In this implementation, the native endianness is
;;; obtained via cond-expand, which should coincide with the
;;; endianness obtained by calling the features procedure.  Of the
;;; R7RS systems I've tested, only one omits endianness from its
;;; (features), and it's a slow interpreter for which the native
;;; endianness probably won't affect performance.
;;;
;;; This implementation defines a 53-bit exact integer constant,
;;; and the procedures that work with byte fields of arbitrary
;;; width may create even larger exact integers.
;;;
;;; FIXME: It should be possible to delay creation of that 53-bit
;;; constant until it's needed, which might be better for systems
;;; that don't support exact 53-bit integers.  It looks as though
;;; most systems R7RS systems either support exact 53-bit integers
;;; or overflow into inexact 53-bit integers; if the constant turns
;;; out to be inexact, then the procedure that needs it will fail
;;; when it is called, which is what would happen if creation of
;;; that constant were delayed.

(library
 (foreign c-bytevectors)
 (export
  c-bytevectors-init
  native-endianness
  c-bytevector-s8-set!
  c-bytevector-s8-ref
  c-bytevector-uchar-ref
  c-bytevector-char-ref
  c-bytevector-char-set!
  c-bytevector-uchar-set!
  c-bytevector-uint-ref
  c-bytevector-sint-ref
  c-bytevector-sint-set!
  c-bytevector-uint-set!
  c-bytevector-u16-ref
  c-bytevector-s16-ref
  c-bytevector-u16-native-ref
  c-bytevector-s16-native-ref
  c-bytevector-u16-set!
  c-bytevector-s16-set!
  c-bytevector-u16-native-set!
  c-bytevector-s16-native-set!
  c-bytevector-u32-ref
  c-bytevector-s32-ref
  c-bytevector-u32-native-ref
  c-bytevector-s32-native-ref
  c-bytevector-u32-set!
  c-bytevector-s32-set!
  c-bytevector-u32-native-set!
  c-bytevector-s32-native-set!
  c-bytevector-u64-ref
  c-bytevector-s64-ref
  c-bytevector-s64-native-ref
  c-bytevector-u64-native-ref
  c-bytevector-u64-set!
  c-bytevector-s64-set!
  c-bytevector-u64-native-set!
  c-bytevector-s64-native-set!
  c-bytevector-ieee-single-native-ref
  c-bytevector-ieee-single-ref
  c-bytevector-ieee-double-native-ref
  c-bytevector-ieee-double-ref
  c-bytevector-ieee-single-native-set!
  c-bytevector-ieee-single-set!
  c-bytevector-ieee-double-native-set!
  c-bytevector-ieee-double-set!)
 (import
  (rnrs base)
  (rnrs control)
  (only (rnrs r5rs) remainder quotient)
  (only (rnrs bytevectors) native-endianness))
 (define make-c-bytevector #f)
 (define c-bytevector-u8-set! #f)
 (define c-bytevector-u8-ref #f)
 (define (c-bytevectors-init make u8-set! u8-ref)
   (set! make-c-bytevector make)
   (set! c-bytevector-u8-set! u8-set!)
   (set! c-bytevector-u8-ref u8-ref))
 (define (complain who . irritants)
   (apply error
          (string-append "illegal arguments passed to " (symbol->string who))
          irritants))
 (define-syntax unspecified (syntax-rules () ((_) (if #f #f))))
 (define-syntax c-bytevector:div (syntax-rules () ((_ x y) (quotient x y))))
 (define-syntax c-bytevector:mod (syntax-rules () ((_ x y) (remainder x y))))
 (define-syntax u8->s8
   (syntax-rules ()
     ((_ octet0) (let ((octet octet0)) (if (> octet 127) (- octet 256) octet)))))
 (define-syntax s8->u8
   (syntax-rules ()
     ((_ val0) (let ((val val0)) (if (negative? val) (+ val 256) val)))))
 (define (make-uint-ref size)
   (lambda (c-bytevector k endianness)
     (c-bytevector-uint-ref c-bytevector k endianness size)))
 (define (make-sint-ref size)
   (lambda (c-bytevector k endianness)
     (c-bytevector-sint-ref c-bytevector k endianness size)))
 (define (make-uint-set! size)
   (lambda (c-bytevector k n endianness)
     (c-bytevector-uint-set! c-bytevector k n endianness size)))
 (define (make-sint-set! size)
   (lambda (c-bytevector k n endianness)
     (c-bytevector-sint-set! c-bytevector k n endianness size)))
 (define (make-ref/native base base-ref)
   (lambda (c-bytevector index)
     (ensure-aligned index base)
     (base-ref c-bytevector index (native-endianness))))
 (define (make-set!/native base base-set!)
   (lambda (c-bytevector index val)
     (ensure-aligned index base)
     (base-set! c-bytevector index val (native-endianness))))
 (define (ensure-aligned index base)
   (if (not (zero? (c-bytevector:mod index base)))
       (error "non-aligned c-bytevector access" index base)))
 (define (make-int-list->c-bytevector c-bytevector-set!)
   (lambda (l endness size)
     (let* ((c-bytevector (make-c-bytevector (* size (length l))))
            (setter!
             (lambda (i n) (c-bytevector-set! c-bytevector i n endness size))))
       (let loop ((i 0) (l l))
         (if (null? l)
             c-bytevector
             (begin (setter! i (car l)) (loop (+ i size) (cdr l))))))))
 (define c-bytevector:single-maxexponent 255)
 (define c-bytevector:single-bias
   (c-bytevector:div c-bytevector:single-maxexponent 2))
 (define c-bytevector:single-hidden-bit (expt 2 23))
 (define c-bytevector:double-maxexponent 2047)
 (define c-bytevector:double-bias
   (c-bytevector:div c-bytevector:double-maxexponent 2))
 (define c-bytevector:double-hidden-bit (expt 2 52))
 (define two^48 (expt 2 48))
 (define two^40 (expt 2 40))
 (define two^32 (expt 2 32))
 (define two^24 (expt 2 24))
 (define two^16 (expt 2 16))
 (define two^8 (expt 2 8))
 (define (c-bytevector:normalized-ieee-parts p q)
   (cond
     ((< p q) (do ((p p (+ p p)) (e 0 (- e 1))) ((>= p q) (values e p q))))
     ((<= (+ q q) p)
      (do ((q q (+ q q)) (e 0 (+ e 1))) ((< p (+ q q)) (values e p q))))
     (else (values 0 p q))))
 (define (c-bytevector:ieee-parts x bias q)
   (cond
     ((nan? x) (values 0 (+ bias bias 1) (- q 1)))
     ((infinite? x) (values (if (positive? x) 0 1) (+ bias bias 1) 0))
     ((zero? x) (values (if (eqv? x -0.0) 1 0) 0 0))
     (else (let* ((sign (if (negative? x) 1 0))
                  (y (exact (abs x)))
                  (num (numerator y))
                  (den (denominator y)))
             (call-with-values
              (lambda () (c-bytevector:normalized-ieee-parts num den))
              (lambda (exponent num den)
                (let ((biased-exponent (+ exponent bias)))
                  (cond
                    ((< 0 biased-exponent (+ bias bias 1))
                     (if (<= den q)
                         (let* ((factor (/ q den)) (num*factor (* num factor)))
                           (if (integer? factor)
                               (values sign biased-exponent num*factor)
                               (error 'c-bytevector:ieee-parts
                                      "this shouldn't happen: "
                                      x
                                      bias
                                      q)))
                         (let* ((factor (/ den q)) (num*factor (/ num factor)))
                           (values sign biased-exponent (round num*factor)))))
                    ((>= biased-exponent (+ bias bias 1))
                     (values (if (positive? x) 0 1) (+ bias bias 1) 0))
                    (else (do ((biased biased-exponent (+ biased 1))
                               (num (round (/ (* q num) den))
                                    (round (c-bytevector:div num 2)))) ((and (< num
                                                                                q)
                                                                             (= biased
                                                                                1))
                                                                        (values
                                                                         sign
                                                                         biased
                                                                         num))))))))))))
 (define (c-bytevector-ieee-double-big-endian-ref c-bytevector k)
   (let* ((byte0 (c-bytevector-u8-ref c-bytevector (+ k 0)))
          (byte1 (c-bytevector-u8-ref c-bytevector (+ k 1)))
          (byte2 (c-bytevector-u8-ref c-bytevector (+ k 2)))
          (byte3 (c-bytevector-u8-ref c-bytevector (+ k 3)))
          (byte4 (c-bytevector-u8-ref c-bytevector (+ k 4)))
          (byte5 (c-bytevector-u8-ref c-bytevector (+ k 5)))
          (byte6 (c-bytevector-u8-ref c-bytevector (+ k 6)))
          (byte7 (c-bytevector-u8-ref c-bytevector (+ k 7)))
          (sign (quotient byte0 128))
          (biased-exponent
           (+ (* 16 (remainder byte0 128)) (quotient byte1 16)))
          (hibits (+ (* 65536 (remainder byte1 16)) (* 256 byte2) byte3))
          (midbits (+ (* 256 byte4) byte5))
          (lobits (+ (* 256 byte6) byte7)))
     (make-ieee-double sign biased-exponent hibits midbits lobits)))
 (define (c-bytevector-ieee-double-little-endian-ref c-bytevector k)
   (let* ((byte0 (c-bytevector-u8-ref c-bytevector (+ k 7)))
          (byte1 (c-bytevector-u8-ref c-bytevector (+ k 6)))
          (byte2 (c-bytevector-u8-ref c-bytevector (+ k 5)))
          (byte3 (c-bytevector-u8-ref c-bytevector (+ k 4)))
          (byte4 (c-bytevector-u8-ref c-bytevector (+ k 3)))
          (byte5 (c-bytevector-u8-ref c-bytevector (+ k 2)))
          (byte6 (c-bytevector-u8-ref c-bytevector (+ k 1)))
          (byte7 (c-bytevector-u8-ref c-bytevector (+ k 0)))
          (sign (quotient byte0 128))
          (biased-exponent
           (+ (* 16 (remainder byte0 128)) (quotient byte1 16)))
          (hibits (+ (* 65536 (remainder byte1 16)) (* 256 byte2) byte3))
          (midbits (+ (* 256 byte4) byte5))
          (lobits (+ (* 256 byte6) byte7)))
     (make-ieee-double sign biased-exponent hibits midbits lobits)))
 (define (c-bytevector-ieee-single-big-endian-ref c-bytevector k)
   (let* ((byte0 (c-bytevector-u8-ref c-bytevector (+ k 0)))
          (byte1 (c-bytevector-u8-ref c-bytevector (+ k 1)))
          (byte2 (c-bytevector-u8-ref c-bytevector (+ k 2)))
          (byte3 (c-bytevector-u8-ref c-bytevector (+ k 3)))
          (sign (quotient byte0 128))
          (biased-exponent
           (+ (* 2 (remainder byte0 128)) (quotient byte1 128)))
          (bits (+ (* 65536 (remainder byte1 128)) (* 256 byte2) byte3)))
     (make-ieee-single sign biased-exponent bits)))
 (define (c-bytevector-ieee-single-little-endian-ref c-bytevector k)
   (let* ((byte0 (c-bytevector-u8-ref c-bytevector (+ k 3)))
          (byte1 (c-bytevector-u8-ref c-bytevector (+ k 2)))
          (byte2 (c-bytevector-u8-ref c-bytevector (+ k 1)))
          (byte3 (c-bytevector-u8-ref c-bytevector (+ k 0)))
          (sign (quotient byte0 128))
          (biased-exponent
           (+ (* 2 (remainder byte0 128)) (quotient byte1 128)))
          (bits (+ (* 65536 (remainder byte1 128)) (* 256 byte2) byte3)))
     (make-ieee-single sign biased-exponent bits)))
 (define (make-ieee-double sign biased-exponent hibits midbits lobits)
   (cond
     ((= biased-exponent c-bytevector:double-maxexponent)
      (if (zero? (+ hibits midbits lobits))
          (if (= 0 sign) +inf.0 -inf.0)
          (if (= 0 sign) +nan.0 +nan.0)))
     ((= 0 biased-exponent)
      (if (and (= 0 hibits) (= 0 midbits) (= 0 lobits))
          (if (= 0 sign) 0.0 -0.0)
          (let* ((x (inexact hibits))
                 (x (+ (* 65536.0 x) (inexact midbits)))
                 (x (+ (* 65536.0 x) (inexact lobits)))
                 (two^51 2251799813685248.0)
                 (x (/ x two^51))
                 (x (* x (expt 2.0 (- c-bytevector:double-bias)))))
            (if (= 0 sign) x (- x)))))
     (else (let* ((hibits (+ 1048576 hibits))
                  (x (inexact hibits))
                  (x (+ (* 65536.0 x) (inexact midbits)))
                  (x (+ (* 65536.0 x) (inexact lobits)))
                  (two^52 4503599627370496.0)
                  (x (/ x two^52))
                  (x (* x
                        (expt 2.0 (- biased-exponent c-bytevector:double-bias)))))
             (if (= 0 sign) x (- x))))))
 (define (make-ieee-single sign biased-exponent bits)
   (cond
     ((= biased-exponent c-bytevector:single-maxexponent)
      (if (zero? bits)
          (if (= 0 sign) +inf.0 -inf.0)
          (if (= 0 sign) +nan.0 +nan.0)))
     ((= 0 biased-exponent)
      (if (= 0 bits)
          (if (= 0 sign) 0.0 -0.0)
          (let* ((x (inexact bits))
                 (two^22 4194304.0)
                 (x (/ x two^22))
                 (x (* x (expt 2.0 (- c-bytevector:single-bias)))))
            (if (= 0 sign) x (- x)))))
     (else (let* ((bits (+ 8388608 bits))
                  (x (inexact bits))
                  (two^23 8388608.0)
                  (x (/ x two^23))
                  (x (* x
                        (expt 2.0 (- biased-exponent c-bytevector:single-bias)))))
             (if (= 0 sign) x (- x))))))
 (define-syntax endianness
   (syntax-rules () ((_ big) 'big) ((_ little) 'little)))
 (define (r6rs:c-bytevector-copy!
          source
          source-start
          target
          target-start
          count)
   (if (>= source-start target-start)
       (do ((i 0 (+ i 1))) ((>= i count))
         (c-bytevector-u8-set!
          target
          (+ target-start i)
          (c-bytevector-u8-ref source (+ source-start i))))
       (do ((i (- count 1) (- i 1))) ((< i 0))
         (c-bytevector-u8-set!
          target
          (+ target-start i)
          (c-bytevector-u8-ref source (+ source-start i))))))
 (define (c-bytevector-s8-ref b k) (u8->s8 (c-bytevector-u8-ref b k)))
 (define (c-bytevector-s8-set! b k val)
   (c-bytevector-u8-set! b k (s8->u8 val)))
 (define (u8-list->c-bytevector vals)
   (let* ((n (length vals)) (b (make-c-bytevector n)))
     (do ((vals vals (cdr vals)) (i 0 (+ i 1))) ((null? vals))
       (c-bytevector-u8-set! b i (car vals)))
     b))
 (define (c-bytevector-uchar-ref c-bytevector index)
   (integer->char (c-bytevector-u8-ref c-bytevector index)))
 (define (c-bytevector-uchar-set! c-bytevector index char)
   (c-bytevector-u8-set! c-bytevector index (char->integer char)))
 (define (c-bytevector-char-ref c-bytevector index)
   (integer->char (c-bytevector-s8-ref c-bytevector index)))
 (define (c-bytevector-char-set! c-bytevector index char)
   (c-bytevector-s8-set! c-bytevector index (char->integer char)))
 (define (c-bytevector-uint-ref c-bytevector index endness size)
   (cond
     ((equal? endness 'big)
      (do ((i 0 (+ i 1))
           (result
            0
            (+ (* 256 result) (c-bytevector-u8-ref c-bytevector (+ index i))))) ((>= i
                                                                                     size)
                                                                                 result)))
     ((equal? endness 'little)
      (do ((i (- size 1) (- i 1))
           (result
            0
            (+ (* 256 result) (c-bytevector-u8-ref c-bytevector (+ index i))))) ((< i
                                                                                    0)
                                                                                 result)))
     (else (c-bytevector-uint-ref c-bytevector index (native-endianness) size))))
 (define (c-bytevector-sint-ref c-bytevector index endness size)
   (let* ((high-byte
           (c-bytevector-u8-ref
            c-bytevector
            (if (eq? endness 'big) index (+ index size -1))))
          (uresult (c-bytevector-uint-ref c-bytevector index endness size)))
     (if (> high-byte 127) (- uresult (expt 256 size)) uresult)))
 (define (c-bytevector-uint-set! c-bytevector index val endness size)
   (case endness
     ((little)
      (do ((i 0 (+ i 1)) (val val (c-bytevector:div val 256))) ((>= i size)
                                                                (unspecified))
        (c-bytevector-u8-set!
         c-bytevector
         (+ index i)
         (c-bytevector:mod val 256))))
     ((big)
      (do ((i (- size 1) (- i 1)) (val val (c-bytevector:div val 256))) ((< i
                                                                            0)
                                                                         (unspecified))
        (c-bytevector-u8-set!
         c-bytevector
         (+ index i)
         (c-bytevector:mod val 256))))
     (else (c-bytevector-uint-set!
            c-bytevector
            index
            val
            (native-endianness)
            size))))
 (define (c-bytevector-sint-set! c-bytevector index val endness size)
   (let ((uval (if (< val 0) (+ val (expt 256 size)) val)))
     (c-bytevector-uint-set! c-bytevector index uval endness size)))
 (define c-bytevector-u16-ref (make-uint-ref 2))
 (define c-bytevector-s16-ref (make-sint-ref 2))
 (define c-bytevector-u16-set! (make-uint-set! 2))
 (define c-bytevector-s16-set! (make-sint-set! 2))
 (define c-bytevector-u16-native-ref (make-ref/native 2 c-bytevector-u16-ref))
 (define c-bytevector-s16-native-ref (make-ref/native 2 c-bytevector-s16-ref))
 (define c-bytevector-u16-native-set!
   (make-set!/native 2 c-bytevector-u16-set!))
 (define c-bytevector-s16-native-set!
   (make-set!/native 2 c-bytevector-s16-set!))
 (define c-bytevector-u32-ref (make-uint-ref 4))
 (define c-bytevector-s32-ref (make-sint-ref 4))
 (define c-bytevector-u32-set! (make-uint-set! 4))
 (define c-bytevector-s32-set! (make-sint-set! 4))
 (define c-bytevector-u32-native-ref (make-ref/native 4 c-bytevector-u32-ref))
 (define c-bytevector-s32-native-ref (make-ref/native 4 c-bytevector-s32-ref))
 (define c-bytevector-u32-native-set!
   (make-set!/native 4 c-bytevector-u32-set!))
 (define c-bytevector-s32-native-set!
   (make-set!/native 4 c-bytevector-s32-set!))
 (define c-bytevector-u64-ref (make-uint-ref 8))
 (define c-bytevector-s64-ref (make-sint-ref 8))
 (define c-bytevector-u64-set! (make-uint-set! 8))
 (define c-bytevector-s64-set! (make-sint-set! 8))
 (define c-bytevector-u64-native-ref (make-ref/native 8 c-bytevector-u64-ref))
 (define c-bytevector-s64-native-ref (make-ref/native 8 c-bytevector-s64-ref))
 (define c-bytevector-u64-native-set!
   (make-set!/native 8 c-bytevector-u64-set!))
 (define c-bytevector-s64-native-set!
   (make-set!/native 8 c-bytevector-s64-set!))
 (define (c-bytevector-ieee-single-native-ref c-bytevector k)
   (cond
     ((equal? (native-endianness) 'little)
      (if (not (= 0 (remainder k 4)))
          (complain 'c-bytevector-ieee-single-native-ref c-bytevector k))
      (c-bytevector-ieee-single-little-endian-ref c-bytevector k))
     (else (if (not (= 0 (remainder k 4)))
               (complain 'c-bytevector-ieee-single-native-ref c-bytevector k))
           (c-bytevector-ieee-single-big-endian-ref c-bytevector k))))
 (define (c-bytevector-ieee-double-native-ref c-bytevector k)
   (cond
     ((equal? (native-endianness) 'little)
      (if (not (= 0 (remainder k 8)))
          (complain 'c-bytevector-ieee-double-native-ref c-bytevector k))
      (c-bytevector-ieee-double-little-endian-ref c-bytevector k))
     (else (if (not (= 0 (remainder k 8)))
               (complain 'c-bytevector-ieee-double-native-ref c-bytevector k))
           (c-bytevector-ieee-double-big-endian-ref c-bytevector k))))
 (define (c-bytevector-ieee-single-native-set! c-bytevector k x)
   (cond
     ((equal? (native-endianness) 'little)
      (if (not (= 0 (remainder k 4)))
          (complain 'c-bytevector-ieee-single-native-set! c-bytevector k x))
      (c-bytevector-ieee-single-set! c-bytevector k x 'little))
     (else (if (not (= 0 (remainder k 4)))
               (complain
                'c-bytevector-ieee-single-native-set!
                c-bytevector
                k
                x))
           (c-bytevector-ieee-single-set! c-bytevector k x 'big))))
 (define (c-bytevector-ieee-double-native-set! c-bytevector k x)
   (cond
     ((equal? (native-endianness) 'little)
      (if (not (= 0 (remainder k 4)))
          (if (not (= 0 (remainder k 8)))
              (complain 'c-bytevector-ieee-double-native-set! c-bytevector k x))
          (c-bytevector-ieee-double-set! c-bytevector k x 'little)))
     (else (if (not (= 0 (remainder k 8)))
               (complain
                'c-bytevector-ieee-double-native-set!
                c-bytevector
                k
                x))
           (c-bytevector-ieee-double-set! c-bytevector k x 'big))))
 (define (c-bytevector-ieee-single-ref c-bytevector k endianness)
   (case endianness
     ((big) (c-bytevector-ieee-single-big-endian-ref c-bytevector k))
     ((little) (c-bytevector-ieee-single-little-endian-ref c-bytevector k))
     (else (complain 'c-bytevector-ieee-single-ref c-bytevector k endianness))))
 (define (c-bytevector-ieee-double-ref c-bytevector k endianness)
   (case endianness
     ((big) (c-bytevector-ieee-double-big-endian-ref c-bytevector k))
     ((little) (c-bytevector-ieee-double-little-endian-ref c-bytevector k))
     (else (complain 'c-bytevector-ieee-double-ref c-bytevector k endianness))))
 (define (c-bytevector-ieee-single-set! c-bytevector k x endianness)
   (call-with-values
    (lambda ()
      (c-bytevector:ieee-parts
       x
       c-bytevector:single-bias
       c-bytevector:single-hidden-bit))
    (lambda (sign biased-exponent frac)
      (define (store! sign biased-exponent frac)
        (if (eq? 'big endianness)
            (begin
              (c-bytevector-u8-set!
               c-bytevector
               k
               (+ (* 128 sign) (c-bytevector:div biased-exponent 2)))
              (c-bytevector-u8-set!
               c-bytevector
               (+ k 1)
               (+ (* 128 (c-bytevector:mod biased-exponent 2))
                  (c-bytevector:div frac (* 256 256))))
              (c-bytevector-u8-set!
               c-bytevector
               (+ k 2)
               (c-bytevector:div (c-bytevector:mod frac (* 256 256)) 256))
              (c-bytevector-u8-set!
               c-bytevector
               (+ k 3)
               (c-bytevector:mod frac 256)))
            (begin
              (c-bytevector-u8-set!
               c-bytevector
               (+ k 3)
               (+ (* 128 sign) (c-bytevector:div biased-exponent 2)))
              (c-bytevector-u8-set!
               c-bytevector
               (+ k 2)
               (+ (* 128 (c-bytevector:mod biased-exponent 2))
                  (c-bytevector:div frac (* 256 256))))
              (c-bytevector-u8-set!
               c-bytevector
               (+ k 1)
               (c-bytevector:div (c-bytevector:mod frac (* 256 256)) 256))
              (c-bytevector-u8-set! c-bytevector k (c-bytevector:mod frac 256))))
        (unspecified))
      (cond
        ((= biased-exponent c-bytevector:single-maxexponent)
         (store! sign biased-exponent frac))
        ((< frac c-bytevector:single-hidden-bit) (store! sign 0 frac))
        (else (store!
               sign
               biased-exponent
               (- frac c-bytevector:single-hidden-bit)))))))
 (define (c-bytevector-ieee-double-set! c-bytevector k x endianness)
   (call-with-values
    (lambda ()
      (c-bytevector:ieee-parts
       x
       c-bytevector:double-bias
       c-bytevector:double-hidden-bit))
    (lambda (sign biased-exponent frac)
      (define (store! sign biased-exponent frac)
        (c-bytevector-u8-set!
         c-bytevector
         (+ k 7)
         (+ (* 128 sign) (c-bytevector:div biased-exponent 16)))
        (c-bytevector-u8-set!
         c-bytevector
         (+ k 6)
         (+ (* 16 (c-bytevector:mod biased-exponent 16))
            (c-bytevector:div frac two^48)))
        (c-bytevector-u8-set!
         c-bytevector
         (+ k 5)
         (c-bytevector:div (c-bytevector:mod frac two^48) two^40))
        (c-bytevector-u8-set!
         c-bytevector
         (+ k 4)
         (c-bytevector:div (c-bytevector:mod frac two^40) two^32))
        (c-bytevector-u8-set!
         c-bytevector
         (+ k 3)
         (c-bytevector:div (c-bytevector:mod frac two^32) two^24))
        (c-bytevector-u8-set!
         c-bytevector
         (+ k 2)
         (c-bytevector:div (c-bytevector:mod frac two^24) two^16))
        (c-bytevector-u8-set!
         c-bytevector
         (+ k 1)
         (c-bytevector:div (c-bytevector:mod frac two^16) 256))
        (c-bytevector-u8-set! c-bytevector k (c-bytevector:mod frac 256))
        (if (not (eq? endianness 'little))
            (begin
              (swap! (+ k 0) (+ k 7))
              (swap! (+ k 1) (+ k 6))
              (swap! (+ k 2) (+ k 5))
              (swap! (+ k 3) (+ k 4))))
        (unspecified))
      (define (swap! i j)
        (let ((bi (c-bytevector-u8-ref c-bytevector i))
              (bj (c-bytevector-u8-ref c-bytevector j)))
          (c-bytevector-u8-set! c-bytevector i bj)
          (c-bytevector-u8-set! c-bytevector j bi)))
      (cond
        ((= biased-exponent c-bytevector:double-maxexponent)
         (store! sign biased-exponent frac))
        ((< frac c-bytevector:double-hidden-bit) (store! sign 0 frac))
        (else (store!
               sign
               biased-exponent
               (- frac c-bytevector:double-hidden-bit)))))))
 (define (string->utf16 string . rest)
   (let* ((endianness
           (cond
             ((null? rest) 'big)
             ((not (null? (cdr rest)))
              (apply complain 'string->utf16 string rest))
             ((eq? (car rest) 'big) 'big)
             ((eq? (car rest) 'little) 'little)
             (else (apply complain 'string->utf16 string rest))))
          (hi (if (eq? 'big endianness) 0 1))
          (lo (- 1 hi))
          (n (string-length string)))
     (define (result-length)
       (do ((i 0 (+ i 1))
            (k 0
               (let ((sv (char->integer (string-ref string i))))
                 (if (< sv 65536) (+ k 2) (+ k 4))))) ((= i n) k)))
     (let ((bv (make-c-bytevector (result-length))))
       (define (loop i k)
         (if (< i n)
             (let ((sv (char->integer (string-ref string i))))
               (if (< sv 65536)
                   (let ((hibits (quotient sv 256))
                         (lobits (remainder sv 256)))
                     (c-bytevector-u8-set! bv (+ k hi) hibits)
                     (c-bytevector-u8-set! bv (+ k lo) lobits)
                     (loop (+ i 1) (+ k 2)))
                   (let* ((x (- sv 65536))
                          (hibits (quotient x 1024))
                          (lobits (remainder x 1024))
                          (hi16 (+ 55296 hibits))
                          (lo16 (+ 56320 lobits))
                          (hi1 (quotient hi16 256))
                          (lo1 (remainder hi16 256))
                          (hi2 (quotient lo16 256))
                          (lo2 (remainder lo16 256)))
                     (c-bytevector-u8-set! bv (+ k hi) hi1)
                     (c-bytevector-u8-set! bv (+ k lo) lo1)
                     (c-bytevector-u8-set! bv (+ k hi 2) hi2)
                     (c-bytevector-u8-set! bv (+ k lo 2) lo2)
                     (loop (+ i 1) (+ k 4)))))))
       (loop 0 0)
       bv))))
