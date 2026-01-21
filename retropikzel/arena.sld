(define-library
  (retropikzel arena)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export make-arena
          arena?
          call-with-arena
          arena-allocate
          free-arena)
  (include "arena.scm"))

