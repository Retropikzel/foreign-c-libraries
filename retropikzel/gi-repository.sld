(define-library
  (retropikzel gi-repository)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export gi-repository-new
          gi-repository-require
          gi-repository-find-by-name
          gi-function-info-invoke)
  (include "gi-repository.scm"))
