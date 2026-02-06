(define-library
  (retropikzel system)
  (import (scheme base)
          (scheme write)
          (scheme process-context)
          (foreign c))
  (export system)
  (include "system.scm"))
