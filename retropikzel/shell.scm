(define previous-exit-code #f)

(define (shell cmd)
  (when (not (string? cmd)) (error "shell: cmd must be string" cmd))
  (call-with-temporary-filename
    (lambda (input-path)
      (let* ((shell-command (string-append cmd
                                           " 1> "
                                           input-path
                                           " 2> "
                                           input-path
                                           " & ")))
        (create-pipe input-path 0777)
        (set! previous-exit-code (system shell-command))
        (pipe-read-string 64000 (open-input-pipe input-path #t))))))

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
