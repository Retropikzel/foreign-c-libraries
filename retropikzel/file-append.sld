(define-library
  (retropikzel file-append)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export with-append-to-file)
  (include "file-append.scm"))
