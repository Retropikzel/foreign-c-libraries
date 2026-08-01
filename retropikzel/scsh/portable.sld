(define-library
  (retropikzel scsh portable)
  (import (scheme base)
          (scheme read)
          (scheme write)
          (scheme file)
          (scheme process-context)
          (srfi 60)
          (srfi 170))
  (export reduce-port
          port-fold
          simplify-file-name
          set-umask
          setenv
          getenv
          glob-quote
          add-after
          add-before
          alist->env
          alist-compress
          alist-delete
          alist-update
          arg
          arg*
          argv
          current-autoreap-policy
          bin-dir
          prefix
          exec-prefix
          lib-dir
          include-dir
          man-dir
          obtain-dot-lock
          )
  (begin (define set-umask set-umask!))
  (include "scsh/portable.scm"))

