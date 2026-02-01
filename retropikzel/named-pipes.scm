;; TODO output-pipe and input-pipe types
;; TODO Check on writing that given pipe is output pipe
;; TODO Check on reading that given pipe is input pipe
(define-c-library libc-stdlib
                  '("stdlib.h" "errno.h" "fcntl.h")
                  libc-name
                  '((additional-versions ("0" "6"))))

;(define-c-procedure c-system libc-stdlib 'system 'int '(pointer))
(define-c-procedure c-mkfifo libc-stdlib 'mkfifo 'int '(pointer int))
(define-c-procedure c-open libc-stdlib 'open 'int '(pointer int int))
(define-c-procedure c-read libc-stdlib 'read 'int '(int pointer int))
(define-c-procedure c-write libc-stdlib 'write 'int '(int pointer int))
(define-c-procedure c-close libc-stdlib 'close 'int '(int))
(define-c-procedure c-perror libc-stdlib 'perror 'void '(pointer))
;(define-c-procedure c-system libc-stdlib 'system 'int '(pointer))
;(define-c-procedure c-tempnam libc-stdlib 'tempnam 'pointer '(pointer pointer))

(define-record-type <input-pipe>
  (make-input-pipe path file-descriptor)
  input-pipe?
  (path input-path)
  (file-descriptor input-file-descriptor))

(define-record-type <output-pipe>
  (make-output-pipe path file-descriptor)
  output-pipe?
  (path output-path)
  (file-descriptor output-file-descriptor))

(define O_RDONLY+O_CREAT 64)
(define O_RDONLY+O_NONBLOCK+O_CREAT 2112)
(define O_WRONLY+O_CREAT 65)
(define O_WRONLY+O_NONBLOCK+O_CREAT 2113)

(define S_IRUSR-S_IWUSR 384)

(define handle-c-errors
  (lambda (msg return-code)
    (when (and (number? return-code)
               (< return-code 0))
      (c-perror (string->c-utf8 msg))
      (error msg return-code))
    return-code))

(define create-pipe
  (lambda (path mode)
    (let* ((path* (string->c-utf8 path))
           (octal-mode (string->number (string-append "#o"
                                                      (number->string mode)))))
      (handle-c-errors (string-append "open-output-pipe mkfifo"
                                      " "
                                      path
                                      " "
                                      (number->string mode))
                       (c-mkfifo path* octal-mode)))))

(define open-input-pipe
  (lambda (path . block?)
    (make-input-pipe path
                     (handle-c-errors (string-append "open-input-pipe open"
                                                     "(Note that: A process can open a FIFO in nonblocking mode. In this case, opening for read-only succeeds even if no one has opened on the write side yet and opening for write-only fails with ENXIO (no such device or address) unless the other end has already been opened.)")
                                      (c-open (string->c-utf8 path)
                                              (if (null? block?)
                                                O_RDONLY+O_NONBLOCK+O_CREAT
                                                O_RDONLY+O_CREAT)
                                              S_IRUSR-S_IWUSR)))))

(define open-output-pipe
  (lambda (path . block?)
    (make-output-pipe path
                      (handle-c-errors (string-append "open-output-pipe open"
                                                      " "
                                                      "(Note that: A process can open a FIFO in nonblocking mode. In this case, opening for read-only succeeds even if no one has opened on the write side yet and opening for write-only fails with ENXIO (no such device or address) unless the other end has already been opened.)")
                                       (c-open (string->c-utf8 path)
                                               (if (null? block?)
                                                 O_WRONLY+O_NONBLOCK+O_CREAT
                                                 O_WRONLY+O_CREAT)
                                               S_IRUSR-S_IWUSR)))))

(define pipe-read-u8-buffer (make-c-bytevector (c-type-size 'u8)))
(define pipe-read-u8
  (lambda (pipe)
    (when (not (input-pipe? pipe))
      (error "Can only read from input-pipe" pipe))
    (let* ((read-count (c-read (input-file-descriptor pipe)
                               pipe-read-u8-buffer
                               (c-type-size 'u8)))
           (byte (if (> read-count 0)
                   (c-bytevector-ref pipe-read-u8-buffer 'u8 0)
                   (eof-object))))
      byte)))

(define pipe-write-u8-buffer (make-c-bytevector (c-type-size 'u8)))
(define pipe-write-u8
  (lambda (byte pipe)
    (when (not (output-pipe? pipe))
      (error "Can only write to output-pipe" pipe))
    (c-bytevector-set! pipe-write-u8-buffer 'u8 0 byte)
    (c-write (output-file-descriptor pipe) pipe-write-u8-buffer 1)))

(define pipe-read-char-buffer (make-c-bytevector (c-type-size 'char)))
(define pipe-read-char
  (lambda (pipe)
    (when (not (input-pipe? pipe))
      (error "Can only read from input-pipe" pipe))
    (let* ((read-count (c-read (input-file-descriptor pipe)
                               pipe-read-char-buffer
                               (c-type-size 'char)))
           (char (if (> read-count 0)
                   (c-bytevector-ref pipe-read-char-buffer 'char 0)
                   (eof-object))))
      char)))

(define pipe-write-char-buffer (make-c-bytevector (c-type-size 'char)))
(define pipe-write-char
  (lambda (char pipe)
    (when (not (output-pipe? pipe))
      (error "Can only write to output-pipe" pipe))
    (c-bytevector-set! pipe-write-char-buffer 'char 0 char)
    (c-write (output-file-descriptor pipe)
             pipe-write-char-buffer
             (c-type-size 'char))))

(define pipe-read-string-old
  (lambda (count pipe)
    (when (not (input-pipe? pipe))
      (error "Can only read from input-pipe" pipe))
    (let* ((buffer (make-c-bytevector (* (c-type-size 'char) count)))
           (read-count (c-read (input-file-descriptor pipe) buffer count))
           (text (string-copy (c-utf8->string buffer))))
      (display "text: ")
      (display text)
      (newline)
      (c-free buffer)
      (if (> read-count 0) text (eof-object)))))

(define pipe-read-string
  (lambda (count pipe)
    (when (not (input-pipe? pipe))
      (error "Can only read from input-pipe" pipe))
    (let* ((buffer (make-c-bytevector (* (c-type-size 'char) count)))
           (read-count (c-read (input-file-descriptor pipe) buffer count))
           (text (c-utf8->string buffer)))
      (c-free buffer)
      (if (> read-count 0) text (eof-object)))))

(define pipe-write-string
  (lambda (text pipe)
    (when (not (output-pipe? pipe))
      (error "Can only write to output-pipe" pipe))
    (let ((count (string-length text))
          (text-pointer (string->c-utf8 text)))
      (c-write (output-file-descriptor pipe) text-pointer count)
      (c-free text-pointer))))

(define pipe-read-line
  (lambda (pipe)
    (letrec ((looper (lambda (c result result-length)
                       (cond ((eof-object? c) c)
                             ((char=? c #\newline)
                              (list->string (reverse result)))
                             (else (looper (pipe-read-char pipe)
                                           (cons c result)
                                           (+ result-length 1)))))))
      (looper (pipe-read-char pipe) (list) 0))))

(define pipe-read
  (lambda (pipe)
    (letrec ((looper (lambda (c result)
                       (cond ((eof-object? c)
                              (if (null? result)
                                (eof-object)
                                (list->string (reverse result))))
                             (else (looper (pipe-read-char pipe)
                                           (cons c result)))))))
      (looper (pipe-read-char pipe) (list)))))

(define close-pipe
  (lambda (pipe)
    (cond ((input-pipe? pipe)
           (c-close (input-file-descriptor pipe)))
          ((output-pipe? pipe)
           (c-close (output-file-descriptor pipe)))
          (else (error "Can not close, not a pipe" pipe)))))
