(import (scheme base)
        (scheme write)
        (scheme file)
        (scheme process-context)
        (retropikzel shell)
        (srfi 64))

(test-begin "shell")

(write (shell "ls"))
(newline)

(write (shell->list "ls"))
(newline)

(write (shell->sexp "echo '(1 2 3)'"))
(newline)

(test-end "shell")
