(define-library
  (retropikzel stdio)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export fopen
          fclose
          ;feof
          ;ferror
          ;fgetc
          ;fgets
          ;fprintf
          ;fputc
          ;fputs
          ;fread
          ;fscanf
          ;fseek
          ;ftell
          ;fwrite
          ;getc
          ;getchar
          ;printf
          ;putc
          ;putchar
          ;puts
          ;remove
          ;rename
          ;rewind
          ;scanf
          ;snprintf
          ;sprintf
          ;sscanf
          )
  (include "stiod.scm"))

