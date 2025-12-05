(define-library
  (retropikzel named-pipes)
  (import (scheme base)
          (scheme write)
          (scheme char)
          (scheme file)
          (scheme process-context)
          (foreign c))
  (export create-pipe
          open-input-pipe
          input-pipe?
          open-output-pipe
          output-pipe?
          pipe-read-u8
          pipe-write-u8
          pipe-read-char
          pipe-write-char
          pipe-read-string
          pipe-write-string
          pipe-read
          pipe-read-line
          close-pipe)
  (include "named-pipes.scm"))


