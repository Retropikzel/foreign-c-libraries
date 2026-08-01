(import (scheme base)
        (scheme write)
        (scheme read)
        (scheme char)
        (scheme file)
        (scheme process-context)
        (retropikzel scsh)
        (retropikzel tap)
        (retropikzel debug)
        (srfi 19)
        (srfi 64))

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
(when (file-exists? "test.test") (delete-file "test.test"))
(with-output-to-file "test.test" (lambda () (display 1)))
(test-equal '("test.test") (glob "*.test"))
(test-equal "." (car (glob ".*")))
(test-end "glob")


(test-begin "glob-quote")
(test-equal "\\*.scm" (glob-quote "*.scm"))
(when (file-exists? "*.test1") (delete-file "*.test1"))
(with-output-to-file "*.test1" (lambda () (display 1)))
(test-equal '("*.test1") (glob (glob-quote "*.test1")))
(test-end "glob-quote")


(test-begin "->uid")
(test-equal 0 (->uid 0))
(test-equal 0 (->uid "root"))
(test-end "->uid")


(test-begin "->username")
(test-equal "root" (->username "root"))
(test-equal "root" (->username 0))
(test-end "->username")


(test-begin "port-fold")
(let-values (((lst) (port-fold (open-input-string "1 2 3") read cons '())))
  (test-equal '(3 2 1) lst))
(test-end "port-fold")


(test-begin "reduce-port")
(let-values (((lst) (reduce-port (open-input-string "1 2 3") read cons '())))
  (test-equal '(3 2 1) lst))
(test-end "port-fold")


(test-begin "simplify-file-name") ;; TODO
(test-end "simplify-file-name")


(test-begin "absolute-file-name")
(test-equal "/tmp" (absolute-file-name "/tmp"))
(test-end "absolute-file-name")


(test-begin "add-after")
(test-equal '(foo baz bar) (add-after 'baz 'foo '(foo bar)))
(test-end "add-after")


(test-begin "add-before")
(test-equal '(baz foo bar) (add-before 'baz 'foo '(foo bar)))
(test-end "add-before")


(test-begin "alist->env")
(test-equal '("one=1" "two=2" "PATH=/tmp:/usr/local/bin")
            (alist->env '(("one" . "1")
                          ("two" . "2")
                          ("PATH" "/tmp" "/usr/local/bin"))))
(test-end "alist->env")


(test-begin "alist-compress")
(test-equal '((one . 1) (two . 2) (three .3) (four . 4))
            (alist-compress '((one . 1) (two . 2) (three .3) (four . 4) (two . 2))))
(test-end "alist-compress")


(test-begin "alist-delete")
(test-equal '((one . 1) (three .3) (four . 4))
            (alist-delete 'two '((one . 1) (two . 2) (three .3) (four . 4) (two . 2))))
(test-end "alist-delete")


(test-begin "alist-update")
(test-equal '((two . 20) (one . 1) (three .3) (four . 4))
            (alist-update 'two 20 '((one . 1) (two . 2) (three .3) (four . 4))))
(test-equal '((two . 20) (one . 1) (three .3) (four . 4))
            (alist-update 'two 20 '((one . 1) (two . 2) (three .3) (four . 4) (two . 2))))
(test-end "alist-update")


(test-begin "arg")
(test-equal 2 (arg '(1 2 3) 2))
(test-equal 200 (arg '(1 2 3) 4 200))
(test-equal 3 (arg '(1 2 3) 3))
(test-equal 3 (arg '(1 2 3) 3 200))
(test-end "arg")


(test-begin "arg*")
(test-equal 2 (arg* '(1 2 3) 2))
(test-equal 2 (arg* '(1 2 3) 2 (lambda () 2)))
(test-equal 2 (arg* '(1 2 3) 20 (lambda () 2)))
(test-end "arg*")


(test-begin "argv")
(test-assert (string? (argv 0)))
(test-end "argv")


(test-begin "autoreap-policy")
(autoreap-policy 'early)
(test-equal 'early (autoreap-policy))
(autoreap-policy 'late)
(test-equal 'late (autoreap-policy))
(autoreap-policy #f)
(test-equal #f (autoreap-policy))
(test-end "autoreap-policy")


(test-begin "sleep")
(let ((start-time (current-time)))
  (sleep 3000)
  (display "Slept for seconds: ")
  (write (time-second (time-difference (current-time) start-time)))
  (newline))
(test-end "sleep")


(test-begin "call-with-string-output-port")
(let* ((procedure (lambda (port) (display "Hello world" port)))
       (out-str (call-with-string-output-port procedure)))
  (test-equal "Hello world" out-str))
(test-end "call-with-string-output-port")


(test-begin "char-ascii?")
(test-assert (char-ascii? #\a))
(test-end "char-ascii?")


(test-begin "char-blank?")
(test-assert (char-blank? #\space))
(test-assert (char-blank? #\tab))
(test-assert (not (char-blank? #\a)))
(test-end "char-blank?")


(test-begin "char-digit?")
(test-assert (char-digit? #\1))
(test-assert (char-digit? #\0))
(test-assert (not (char-digit? #\a)))
(test-end "char-digit?")


(test-begin "char-graphic?")
(test-assert (char-graphic? #\a))
(test-end "char-graphic?")


(test-begin "char-hex-digit?")
(test-assert (char-hex-digit? #\1))
(test-assert (char-hex-digit? #\a))
(test-assert (not (char-hex-digit? #\space)))
(test-end "char-hex-digit?")


(test-begin "char-iso-control?")
(test-assert (not (char-iso-control? #\space)))
(test-end "char-iso-control?")


(test-begin "char-letter+digit?")
(test-assert (char-letter+digit? #\1))
(test-assert (char-letter+digit? #\a))
(test-end "char-letter+digit?")


(test-begin "char-letter?")
(test-assert (not (char-letter? #\1)))
(test-assert (char-letter? #\a))
(test-end "char-letter?")


(test-begin "char-punctuation?")
(test-assert (not (char-punctuation? #\a)))
(test-assert (char-punctuation? #\!))
(test-end "char-punctuation?")


(test-begin "char-title-case?")
(test-assert (not (char-title-case? #\a)))
(test-end "char-title-case?")


#| FIXME
(test-begin "cwd")
(debug (cwd))
(test-assert (string? (cwd)))
(test-assert (char=? (string-ref (cwd) 0) #\/))
(test-end "cwd")
|#


#| FIXME
(test-begin "chdir")
(let ((test-dir (cwd)))
  (debug 0)
  (chdir "/tmp")
  (debug (cwd))
  (test-assert (string=? (cwd) "/tmp"))
  (debug 1)
  (chdir test-dir)
  (debug 2)
  (test-assert (string=? (cwd) test-dir))
  (when (not (string=? (cwd) test-dir))
    (error "Test did not change back to test directory")))
(test-end "chdir")
|#


(test-begin "command-line")
(test-assert (list? (command-line)))
(test-end "command-line")


(test-begin "command-line-arguments")
(test-assert (list? (command-line-arguments)))
(test-end "command-line-arguments")


#| FIXME
(test-begin "delete-filesys-object")
(let ((file "/tmp/scschtest1.txt"))
  (when (file-exists? file) (delete-file file))
  (with-output-to-file file (lambda () (display 1)))
  (test-assert (file-exists? file))
  (delete-filesys-object file)
  (test-assert (not (file-exists? file)))
  (when (file-exists? file) (delete-file file)))
(test-end "delete-filesys-object")
|#


#| FIXME
(test-begin "file-directory?")
(test-assert (file-directory? "/tmp" #f))
(let ((file "/tmp/scsch-file-directory?.txt"))
  (when (file-exists? file) (delete-file file))
  (with-output-to-file file (lambda () (display 1)))
  (test-assert (not (file-directory? file #f)))
  (when (file-exists? file) (delete-file file)))
(test-end "file-directory?")
|#


#| FIXME
(test-begin "home-dir")
(test-assert (string? (home-dir)))
(test-end "home-dir")
|#


(test-begin "directory-as-file-name")
(test-equal "/" (directory-as-file-name "/"))
(test-equal "." (directory-as-file-name ""))
(test-equal "/tmp" (directory-as-file-name "/tmp/"))
(test-end "directory-as-file-name")


(test-begin "env->alist")
(test-equal '(("one" . "1") ("two" . "2") ("PATH" . "/tmp:/tmp/bin"))
            (env->alist "one=1\ntwo=2\nPATH=/tmp:/tmp/bin"))
(test-end "env->alist")


(test-begin "error-output-port")
(test-assert (port? (error-output-port)))
(test-end "error-output-port")


(test-end "scsh")
