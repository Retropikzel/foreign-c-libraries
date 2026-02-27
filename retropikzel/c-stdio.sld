(define-library
  (retropikzel c-stdio)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export fopen
          fclose
          feof
          ferror
          fgetc
          fgets
          ;fprintf ;; TODO
          fputc
          fputs
          fread
          ;fscanf ;; TODO
          fseek
          ftell
          fwrite
          getc
          getchar
          ;printf ;; TODO
          putc
          putchar
          puts
          remove
          rename
          rewind
          ;scanf ;; TODO
          ;snprintf ;; TODO
          ;sprintf ;; TODO
          ;sscanf ;; TODO
          )
  (include "c-stdio.scm"))

