(define-library
  (retropikzel gtk-webview)
  (import (scheme base)
          (scheme write)
          (foreign c))
  (export gtk-webview)
  (include "gtk-webview.scm"))
