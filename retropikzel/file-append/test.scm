(test-begin "file-append")

(define file-path "/tmp/file-append-test.txt")
(when (file-exists? file-path) (delete-file file-path))

(with-output-to-file file-path (lambda () (display "Hello")))
(test-equal "Hello" (with-input-from-file file-path (lambda () (read-line))))

(with-append-to-file file-path (lambda () (display " world")))
(test-equal "Hello world" (with-input-from-file file-path (lambda () (read-line))))

(test-end "file-append")
