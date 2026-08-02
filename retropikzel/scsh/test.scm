(import (scheme base)
        (scheme write)
        (scheme read)
        (scheme char)
        (scheme file)
        (scheme process-context)
        (retropikzel scsh)
        (retropikzel tap)
        (retropikzel debug)
        (srfi 14)
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


#| FIXME
(test-begin "glob")
(when (file-exists? "test.test") (delete-file "test.test"))
(with-output-to-file "test.test" (lambda () (display 1)))
(test-equal '("test.test") (glob "*.test"))
(test-equal "." (car (glob ".*")))
(test-end "glob")
|#


#| FIXME
(test-begin "glob-quote")
(test-equal "\\*.scm" (glob-quote "*.scm"))
(when (file-exists? "*.test1") (delete-file "*.test1"))
(with-output-to-file "*.test1" (lambda () (display 1)))
(test-equal '("*.test1") (glob (glob-quote "*.test1")))
(test-end "glob-quote")
|#


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


(test-begin "file-last-access")
(test-assert (time? (file-last-access "/tmp" #f)))
(test-end "file-last-access")


(test-begin "file-last-mod")
(test-assert (time? (file-last-mod "/tmp" #f)))
(test-end "file-last-mod")


(test-begin "file-last-status-change")
(test-assert (time? (file-last-status-change "/tmp" #f)))
(test-end "file-last-status-change")


(test-begin "file-mode")
(test-assert (integer? (file-mode "/tmp" #f)))
(test-end "file-mode")


(test-begin "file-name-as-directory")
(test-equal "" (file-name-as-directory "."))
(test-equal "/" (file-name-as-directory "/"))
(test-equal "/" (file-name-as-directory ""))
(test-equal "/tmp/" (file-name-as-directory "/tmp"))
(test-equal "/tmp/" (file-name-as-directory "/tmp/"))
(test-end "file-name-as-directory")


(test-begin "file-name-directory")
(test-equal "/tmp/" (file-name-directory "/tmp/hello.txt"))
(test-equal "" (file-name-directory "hello.txt"))
(test-equal "lol/" (file-name-directory "lol/hello.txt"))
(test-equal "" (file-name-directory ""))
(test-equal "/usr/" (file-name-directory "/usr/bdc"))
(test-equal "/usr/bdc/" (file-name-directory "/usr/bdc/"))
(test-equal "bdc/" (file-name-directory "bdc/.login"))
(test-equal "" (file-name-directory "main.c"))
(test-equal "" (file-name-directory "/"))
(test-equal "" (file-name-directory ""))
(test-end "file-name-directory")


(test-begin "file-name-directory?")
(test-assert (file-name-directory? "/"))
(test-assert (not (file-name-directory? ".")))
(test-assert (file-name-directory? ""))
(test-assert (file-name-directory? "/tmp/"))
(test-assert (not (file-name-directory? "/tmp")))
(test-end "file-name-directory?")


(test-begin "file-name-extension")
(test-equal ".bar" (file-name-extension "foo.bar"))
(test-equal "" (file-name-extension "foobar"))
(test-equal "" (file-name-extension ""))
(test-end "file-name-extension")


(test-begin "file-name-non-directory?")
(test-assert (not (file-name-non-directory? "/")))
(test-assert (file-name-non-directory? "."))
;(test-assert (not (file-name-non-directory? ""))) ;; FIXME
(test-assert (not (file-name-non-directory? "/tmp/")))
(test-assert (file-name-non-directory? "/tmp"))
(test-end "file-name-non-directory?")


(test-begin "file-name-nondirectory")
(test-equal "ian" (file-name-nondirectory "/usr/ian"))
(test-equal "" (file-name-nondirectory "/usr/ian/"))
(test-equal ".login" (file-name-nondirectory "ian/.login"))
(test-equal "main.c" (file-name-nondirectory "main.c"))
(test-equal "" (file-name-nondirectory ""))
(test-equal "/" (file-name-nondirectory "/"))
(test-end "file-name-nondirectory")

(test-begin "file-name-sans-extension")
(test-equal "foo" (file-name-sans-extension "foo.bar"))
(test-equal "foobar" (file-name-sans-extension "foobar"))
(test-end "file-name-sans-extension")


(test-begin "file-nlinks")
(test-assert (number? (file-nlinks "/tmp" #f)))
(test-end "file-nlinks")


(test-begin "file-owner")
(test-assert (number? (file-owner "/tmp" #f)))
(test-end "file-owner")


(test-begin "home-directory")
(test-equal home-directory (get-environment-variable "HOME"))
(test-end "home-directory")


#| FIXME
(test-begin "home-file")
(test-assert (string? (home-file "/foo.bar")))
(test-end "home-file")
|#


(test-begin "host")
(test-assert (string? (host)))
(test-end "host")


(test-begin "make-char-port-filter")
(test-assert (procedure? (make-char-port-filter char-downcase)))
(let ((file "/tmp/scsch-make-char-port-filter.txt"))
  (when (file-exists? file) (delete-file file))
  (with-output-to-file file (lambda () (display "ABC")))
  (let* ((file-content
           (with-input-from-file
             file
             (lambda ()
               (parameterize
                 ((current-output-port (open-output-string)))
                 (apply (make-char-port-filter char-downcase) '())
                 (get-output-string (current-output-port)))))))
    (test-equal "abc" file-content)
    (when (file-exists? file) (delete-file file))))
(test-end "make-char-port-filter")


(test-begin "make-string-port-filter")
(test-assert (procedure? (make-string-port-filter string-downcase)))
(let ((file "/tmp/scsch-make-string-port-filter.txt"))
  (when (file-exists? file) (delete-file file))
  (with-output-to-file file (lambda () (display "ABC")))
  (let* ((file-content
           (with-input-from-file
             file
             (lambda ()
               (parameterize
                 ((current-output-port (open-output-string)))
                 (apply (make-string-port-filter string-downcase) '())
                 (get-output-string (current-output-port)))))))
    (test-equal "abc" file-content)
    (when (file-exists? file) (delete-file file))))
(test-end "make-string-port-filter")


(test-begin "parent-pid")
(test-assert (number? (parent-pid)))
(test-end "parent-pid")


(test-begin "parse-file-name")
(test-equal '("/tmp/" "foo" ".bar") (parse-file-name "/tmp/foo.bar"))
(test-end "parse-file-name")


(test-begin "path-list->file-name")
(test-equal "src/des/main.c" (path-list->file-name '("src" "des" "main.c")))
(test-equal "/src/des/main.c" (path-list->file-name '("" "src" "des" "main.c")))
(test-equal "/usr/shivers/src/des/main.c"
            (path-list->file-name '("src" "des" "main.c") "/usr/shivers"))
(test-end "path-list->file-name")


(test-begin "port->list")
(test-equal '(foo bar baz) (port->list read (open-input-string "foo bar baz")))
(test-end "port->list")


(test-begin "port->sexp-list")
(test-equal '(foo bar baz (1 2 3))
            (port->sexp-list (open-input-string "foo bar baz (1 2 3)")))
(test-end "port->sexp-list")


(test-begin "port->string")
(test-equal "1 2 3 (1 2 3)" (port->string (open-input-string "1 2 3 (1 2 3)")))
(test-end "port->string")


(test-begin "port->string-list")
(test-equal '("foo" "bar" "baz")
            (port->string-list (open-input-string "foo\nbar\nbaz\n")))
(test-end "port->string-list")


(test-begin "read-delimited")
(test-equal "foo" (read-delimited "1"
                                  (open-input-string "foo1bar2baz3")))
(test-equal "foo" (read-delimited char-set:digit
                                  (open-input-string "foo1bar2baz3")))
(test-equal "foo" (read-delimited char-set:digit
                                  (open-input-string "foo1bar2baz3")
                                  'trim))
(let ((port (open-input-string "foo1bar2baz3")))
  (test-equal "foo" (read-delimited char-set:digit port 'peek))
  (test-equal #\1 (read-char port)))
(test-equal "foo1" (read-delimited char-set:digit
                                  (open-input-string "foo1bar2baz3")
                                  'concat))
(test-end "read-delimited")


(test-begin "read-line")
(test-equal "foo" (read-line (open-input-string "foo\nbar\nbaz\n")))
(test-equal "foo" (read-line (open-input-string "foo\nbar\nbaz\n")))
(test-equal "foo" (read-line (open-input-string "foo\nbar\nbaz\n") 'trim))
(let ((port (open-input-string "foo\nbar\nbaz\n")))
  (test-equal "foo" (read-line port 'peek))
  (test-equal #\newline (read-char port)))
(test-equal "foo\n" (read-line (open-input-string "foo\nbar\nbaz\n") 'concat))
(test-end "read-line")


(test-end "scsh")
