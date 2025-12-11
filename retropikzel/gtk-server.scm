(define-c-library libc
                  '("stdlib.h" "stdio.h" "unistd.h")
                  libc-name
                  '((additional-versions ("0" "6"))))
(define-c-procedure c-tempnam libc 'tempnam 'pointer '(pointer pointer))
(define temp-prefix (string->c-utf8 "scmgtk"))
(define (temp-name) (c-utf8->string (c-tempnam (make-c-null) temp-prefix)))
(define gtk-server-display pipe-write-string)
(define gtk-server-newline (lambda (pipe) (pipe-write-char #\newline pipe)))
(define (gtk-server-read-line pipe)
  (let ((result (pipe-read-line pipe)))
    (if (eof-object? result)
      (gtk-server-read-line pipe)
      result)))
(define input-path (temp-name))
(define output-path (temp-name))
(define (run-program program)
  (let* ((shell-command (string-append program
                                       " < "
                                       output-path
                                       " 1> "
                                       input-path
                                       " 2> "
                                       input-path
                                       " & ")))
    (create-pipe input-path 0777)
    (create-pipe output-path 0777)
    (system shell-command)
    (list (open-input-pipe input-path)
          (open-output-pipe output-path))))

(define gtk-server-input #f)
(define gtk-server-output #f)

(define gtk-server-start
  (lambda log-file
    (let ((pipes (if (null? log-file)
                   (run-program "gtk-server -stdin")
                   (run-program (string-append "gtk-server "
                                               "-log=" (car log-file)
                                               " -stdin")))))
      (set! gtk-server-input (cadr pipes))
      (set! gtk-server-output (car pipes)))))


(define (gtk command)
  (gtk-server-display (string-append command (string #\newline))
                      gtk-server-input)
  (gtk-server-read-line gtk-server-output))
