(define-c-library libc
                  '("stdlib.h")
                  libc-name
                  '((additional-versions ("6"))))
(define-c-library c-gi
                  '("girepository/girepository.h")
                  "girepository-2.0"
                  '((additional-versions ("0"))))

(define-c-procedure gi-repository-new c-gi 'gi_repository_new 'pointer '())
(define-c-procedure gi-repository-require c-gi 'gi_repository_require 'pointer '(pointer pointer pointer int pointer))
(define-c-procedure gi-repository-find-by-name c-gi 'gi_repository_find_by_name 'pointer '(pointer pointer pointer))
(define-c-procedure gi-function-info-invoke c-gi 'gi_function_info_invoke 'int '(pointer pointer int pointer int pointer pointer))
