(define-library
  (retropikzel shell)
  (import (scheme base)
          (scheme write)
          (scheme read)
          (scheme file)
          (srfi 170)
          (foreign c)
          (retropikzel system)
          (retropikzel named-pipes))
  (export shell
          shell->list
          shell->sexp
          shell-exit-code)
  (include "shell.scm"))



