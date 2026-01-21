(define-record-type <arena>
  (internal-make-arena pointer size fixed?)
  arena?
  (pointer arena-pointer)
  (size arena-size)
  (fixed? arena-fixed?))

(define make-arena
  (lambda options
    #t
  ))

(define (call-with-arena arena thunk)
  #t
  )

(define (arena-allocate arena size)
  #t
  )

(define (free-arena arena)
  #t
  )
