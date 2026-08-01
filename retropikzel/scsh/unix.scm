(define-c-library libc
                  '("stdlib.h" "string.h" "stdio.h" "glob.h" "unistd.h")
                  #f
                  ())
(define-c-procedure c-perror libc 'perror 'void '(pointer))
(define (perror procedure-name msg . objs)
  (let ((procedure-name* (string->c-bytevector
                           (string-append procedure-name " error"))))
    (c-perror procedure-name*)
    (c-bytevector-free procedure-name*))
  (apply error (cons (string-append procedure-name " error: ") objs)))


(define *temp-file-template*
  (cond ((get-environment-variable "TMPDIR")
         (string-append (get-environment-variable "TMPDIR")
                        "/"
                        (number->string (pid))
                        ".~a"))
        (else
          (string-append "/var/tmp/" (number->string (pid)) ".~a"))))

(define (->uid uid/username)
  (cond
    ((exact-integer? uid/username) uid/username)
    ((string? uid/username)
     (letrec*
       ((username-length (string-length uid/username))
        (looper (lambda (line)
                  (if (eof-object? line)
                    #f
                    (let ((line-length (string-length line)))
                      (if (and (>= line-length username-length)
                               (string=? uid/username
                                         (string-copy line
                                                      0
                                                      username-length)))
                        (string->number (list-ref (string-split line #\:) 2))
                        (looper (read-line))))))))
       (with-input-from-file "/etc/passwd" (lambda () (looper (read-line))))))
    (else (error (string-append "->uid error: uid/username must be either"
                                " exact integer or string")))))

(define (->username uid/username)
  (cond ((string? uid/username) uid/username)
        ((exact-integer? uid/username)
         (letrec*
           ((looper (lambda (line)
                      (if (eof-object? line)
                        #f
                        (let* ((line-length (string-length line))
                               (line-list (string-split line #\:))
                               (line-list-length (length line-list)))
                          (if (and (>= line-list-length 3)
                                   (= (string->number (list-ref line-list 2))
                                      uid/username))
                            (car line-list)
                            (looper (read-line))))))))
           (with-input-from-file "/etc/passwd" (lambda () (looper (read-line))))))
        (else (error (string-append "->username error: uid/username must be either"
                                    " exact integer or string")))))

(define-c-procedure c-realpath libc 'realpath 'pointer '(pointer pointer))
(define (absolute-file-name fname . dir)
  (cond ((not (string? fname))
         (error "abosolute-file-name error: fname must bes string"))
        ((= (string-length fname) 0) "/")
        (else (let* ((fname* (string->c-bytevector fname))
                     (path* (c-realpath fname* (c-bytevector-null))))
                (if (c-bytevector-null? path*)
                  (let ((error* (string->c-bytevector "absolute-file-name")))
                    (c-perror error*)
                    (c-bytevector-free fname* path* error*)
                    (error "" fname))
                  (let ((path (c-bytevector->string path*)))
                    (c-bytevector-free fname* path*)
                    path))))))

(define-c-procedure c-glob libc 'glob 'int '(pointer int pointer pointer))
(define-c-procedure c-globfree libc 'globfree 'int '(pointer))
(define-c-struct-type glob-struct '((gl_pathc int) (gl_pathv pointer) (gl_offs int)))
(define glob
  (lambda paths
    (let ((result '()))
      (for-each
        (lambda (path)
          (let ((glob-struct* (make-c-bytevector (c-type-size glob-struct)))
                (path* (string->c-bytevector path)))
            (c-glob path* 0 (c-bytevector-null) glob-struct*)
            (letrec
              ((path-count (c-bytevector-ref glob-struct* glob-struct 'gl_pathc))
               (looper
                 (lambda (count)
                   (when (< count path-count)
                     (let* ((list-path*
                              (c-bytevector-ref
                                (c-bytevector-ref glob-struct* glob-struct 'gl_pathv)
                                'pointer
                                (* (c-type-size 'pointer) count)))
                            (list-path-string (c-bytevector->string list-path*)))
                       (set! result (append result (list list-path-string)))
                       (c-bytevector-free list-path*)
                       (looper (+ count 1)))))))
              (looper 0)
              (c-bytevector-free path* glob-struct*))))
        paths)
      result)))

(define-c-procedure c-setsid libc 'setsid 'int '())
(define (become-session-leader)
  (let ((result (c-setsid)))
    (when (< result 0)
      (error "become-session-leader error: Most propably already session leader"
             result))
    result))

(define-c-procedure c-chdir libc 'chdir 'int '(pointer))
(define chdir
  (lambda args
    (let ((fname (if (null? args) (home-dir) (car args))))
      (when (not (string? fname)) (error "chdir error: fname must be string"))
      (let* ((fname* (string->c-bytevector fname))
             (result (c-chdir fname*)))
        (c-bytevector-free fname*)
        (when (= result -1)
          (perror "chdir" "could not change directory"))))))

(define-c-procedure c-getcwd libc 'getcwd 'pointer '(pointer int))
(define (cwd)
  (letrec
    ((start-size 128)
     (looper
       (lambda (size)
         (let* ((buffer* (make-c-bytevector size))
                (cwd* (c-getcwd buffer* size)))
           (if (c-bytevector-null? cwd*)
             (looper (* size 2))
             (let ((result (c-bytevector->string buffer*)))
               (c-bytevector-free cwd* buffer*)
               result))))))
    (looper start-size)))

(define (delete-filesys-object fname)
  (when (not (string? fname))
    (error "delete-filesys-object error: fname must be string"))
  (if (file-directory? fname #f)
    (delete-directory fname)
    (guard (condition (else #t))
      (delete-file fname))))

(define (file-directory? fname/port . chase?)
  (when (not (or (string? fname/port)
                 (port? fname/port)))
    (error "file-directory? error: fname/port must be string or port"))
  (when (and (not (null? chase?))
             (not (equal? (car chase?) #t))
             (not (equal? (car chase?) #f)))
    (error "file-directory? error: chase? must be boolean"))
  (let ((f-info (file-info fname/port (if (null? chase?) #t (car chase?)))))
    (file-info-directory? f-info)))

(define home-dir
  (lambda args
    (let ((user (if (null? args)
                  (user-info:name (user-info (user-uid)))
                  (car args))))
      (when (not (string? user))
        (error "home-dir error: user must be string" user))
      (letrec
        ((username-length (string-length user))
         (looper (lambda (line)
                   (if (eof-object? line)
                     #f
                     (let ((line-length (string-length line)))
                       (if (and (>= line-length username-length)
                                (string=? user
                                          (string-copy line
                                                       0
                                                       username-length)))
                           (list-ref (string-split line #\:) 5)
                         (looper (read-line)))))))
         (home-dir-path (with-input-from-file
                          "/etc/passwd"
                          (lambda () (looper (read-line))))))
        (when (not home-dir-path)
          (error "home-dir error: home directory not found, user does not exist?"
                 user))
        home-dir-path))))
