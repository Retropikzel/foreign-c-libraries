
(test-begin "shell")

(test-equal "Linux\n" (shell "uname"))
(test-equal 0 (shell-exit-code))

(test-equal '("Linux") (shell->list "uname"))
(test-equal 0 (shell-exit-code))

(test-equal '(1 2 3) (shell->sexp "echo '(1 2 3)'"))
(test-equal 0 (shell-exit-code))


(test-end "shell")
