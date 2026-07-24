(import (scheme base)
        (scheme write)
        (scheme read)
        (scheme char)
        (scheme file)
        (scheme process-context)
        (retropikzel scsh)
        (srfi 64)
        (retropikzel tap))

(test-runner-current (tap-runner))

(test-begin "scsh")

(test-begin "setenv")
(setenv "SCSH_TEST1" "foobar")
(test-equal "foobar" (get-environment-variable "SCSH_TEST1"))
(test-end "setenv")


(test-begin "getenv")
(test-equal "foobar" (getenv "SCSH_TEST1"))
(test-end "getenv")


(test-begin "glob")
(test-equal '("test.hehe") (glob "*.hehe"))
(test-end "glob")



(test-end "scsh")
