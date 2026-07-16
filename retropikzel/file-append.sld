(define-library
  (retropikzel file-append)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (cond-expand (mosh (import (srfi 39))
                     (else)))
  (export with-append-to-file)
  (include "file-append.scm"))
