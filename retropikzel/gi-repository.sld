(define-library
  (retropikzel gi-repository)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export gi-repository
          gi-repository-info
          gi-function-info
          gi-invoke

          gi-struct
          gi-struct-method-info
          gi-struct-namespace
          gi-struct-name
          gi-struct-invoke

          gi-object
          gi-object-info
          gi-object-namespace
          gi-object-name
          gi-object-method-info
          gi-object-invoke
          gi-info-namespace

          )
  (include "gi-repository.scm"))
