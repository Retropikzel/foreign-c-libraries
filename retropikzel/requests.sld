(define-library
  (retropikzel requests)
  (import (scheme base)
          (scheme write)
          (scheme char)
          (scheme file)
          (scheme process-context)
          (foreign c))
  (export request
          response-status-code
          response-text
          response-bytes
          response-headers
          ;response-cookies
          )
  (include "requests.scm"))

