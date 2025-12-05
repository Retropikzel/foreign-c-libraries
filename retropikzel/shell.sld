(define-library
  (retropikzel shell)
  (import (scheme base)
          (scheme write)
          (scheme read)
          (scheme file)
          (foreign c)
          (retropikzel named-pipes))
  (export shell
          shell->list
          shell->sexp)
  (include "shell.scm"))



