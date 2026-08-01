(define (string-split str split-by)
  (read (open-input-string
          (list->string
            (append
              (list #\( #\")
              (apply
                append
                (map
                  (lambda (c)
                    (if (char=? c split-by)
                      (list #\" #\space #\")
                      (list c)))
                  (string->list str)))
              (list #\" #\)))))))

(define (string-join lst join-by)
  (apply string-append
         (cdr (apply append (map (lambda (item) (list join-by item)) lst)))))

