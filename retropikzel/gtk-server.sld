(define-library
  (retropikzel gtk-server)
  (import (scheme base)
          (scheme write)
          (scheme file)
          (foreign c)
          (retropikzel system)
          (retropikzel named-pipes))
  (export gtk-server-start
          gtk)
  (include "gtk-server.scm"))
