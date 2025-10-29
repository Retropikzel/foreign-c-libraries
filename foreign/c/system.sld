(define-library
  (foreign c system)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export system)
  (include "system.scm"))
