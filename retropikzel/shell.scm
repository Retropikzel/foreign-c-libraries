(define-c-library libc '("stdlib.h" "stdio.h" "unistd.h") #f '())
(define-c-procedure c-tempnam libc 'tempnam 'pointer '(pointer pointer))

(define previous-exit-code #f)

(define (shell cmd)
  (when (not (string? cmd)) (error "shell: cmd must be string" cmd))
  (let* ((temp-prefix (string->c-bytevector "npcmd"))
         (temp-name (lambda ()
                      (c-bytevector->string (c-tempnam (c-bytevector-null)
                                                 temp-prefix))))
         (input-path (temp-name))
         (shell-command (string-append cmd
                                       " 1> "
                                       input-path
                                       " 2> "
                                       input-path
                                       " & ")))
    (create-pipe input-path 0777)
    (set! previous-exit-code (system shell-command))
    (pipe-read-string 64000 (open-input-pipe input-path #t))))

(define (lines->list port result)
  (let ((line (read-line port)))
    (if (eof-object? line)
      (reverse result)
    (lines->list port (cons line result)))))

(define (shell->list cmd)
  (lines->list (open-input-string (shell cmd)) '()))

(define (shell->sexp cmd)
  (read (open-input-string (shell cmd))))

(define (shell-exit-code) previous-exit-code)
