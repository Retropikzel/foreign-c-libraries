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
          shell->sexp
          shell-exit-code)
  (include "shell.scm"))



