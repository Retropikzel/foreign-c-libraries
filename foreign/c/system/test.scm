(import (scheme base)
        (scheme write)
        (scheme file)
        (scheme process-context)
        (foreign c system)
        (srfi 64))

(test-begin "foreign-c-system")

(define testfile "/tmp/foreign-c-system-test.txt")

(define exit-code1 (system (apply string-append `("echo \"Hello\" > " ,testfile))))

(test-assert (= exit-code1 0))

(define text (with-input-from-file testfile (lambda () (read-line))))

(test-assert (string=? text "Hello"))

(define exit-code2 (system "no-such-command"))

(test-assert (> exit-code2 0))

(test-end "foreign-c-system")
