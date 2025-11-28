(import (scheme base)
        (scheme write)
        (scheme file)
        (scheme process-context)
        (foreign c shell)
        (srfi 64))

(test-begin "foreign-c-shell")

(display "Hello")

(test-end "foreign-c-shell")
