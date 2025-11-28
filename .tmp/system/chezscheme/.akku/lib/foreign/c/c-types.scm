(define c-type-signed?
  (lambda (type)
    (if (member type '(int8 int16 int32 int64 char short int long float double))
      #t
      #f)))

(define c-type-unsigned?
  (lambda (type)
    (if (member type '(uint8 uint16 uint32 uint64 unsigned-char unsigned-short unsigned-int unsigned-long))
      #t
      #f)))
