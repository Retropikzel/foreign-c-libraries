(define-c-library libc
                  '("stdlib.h" "stdio.h" "unistd.h")
                  libc-name
                  '((additional-versions ("0" "6"))))

(define-c-procedure c-tempnam libc 'tempnam 'pointer '(pointer pointer))
(define-c-procedure c-system libc 'system 'int '(pointer))

(define (shell cmd)
  (let* ((temp-prefix (string->c-utf8 "npcmd"))
         (temp-name (lambda ()
                      (c-utf8->string (c-tempnam (make-c-null)
                                                 temp-prefix))))
         (input-path (temp-name))
         (shell-command (string-append cmd
                                       " 1> "
                                       input-path
                                       " 2> "
                                       input-path
                                       " & ")))
    (create-pipe input-path 0777)
    (c-system (string->c-utf8 shell-command))
    (pipe-read-string 64000 (open-input-pipe input-path #t))))

(define (lines->list port result)
  (let ((line (read-line port)))
    (if (eof-object? line)
      (reverse result)
    (lines->list port (cons line result)))))

(define (shell->list cmd)
  (lines->list (open-input-string (shell cmd)) '()))

(define (shell->sexp cmd)
  (read (open-input-string (shell cmd)) '()))
