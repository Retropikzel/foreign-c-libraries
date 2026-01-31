(define-c-library libc '("stdio.h") libc-name '((additional-versions ("0" "6"))))
(define-c-procedure internal-fopen libc 'fopen 'pointer '(pointer poiner))
(define-c-procedure internal-fclose libc 'fclose 'int '(pointer))

(define-record-type <stdio-file>
  (make-stdio-file file)
  stdio-file?
  (file stdio-file))

(define modes `("r" "w" "a" "r+" "w+" "a+" "rb" "wb" "ab" "rb+" "wb+" "ab+"))

(define (fopen filename mode)
  (when (not (string? filename)) (error "fopen: Filename must be string"))
  (when (not (string? mode)) (error "fopen: Mode must be string"))
  (when (not (member mode modes))
    (error (string-append "fopen: Mode not in allowed modes of "
                          (apply (lambda (item) (string-append mode " "))
                                 modes))))
  (let* ((filename-pointer (string->c-utf8 filename))
         (mode-pointer (string->c-utf8 mode))
         (file (make-stdio-file (fopen filename mode))))
    (c-free filename-pointer)
    (c-free mode-pointer)
    file))

(define (fclose file)
  (when (not (stdio-file? file)) (error "fclose: File must be stdio-file"))
  (internal-fclose (stdio-file file)))

