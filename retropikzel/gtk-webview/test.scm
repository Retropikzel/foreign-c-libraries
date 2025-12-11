(import (scheme base)
        (scheme write)
        (retropikzel gtk-webview))

(define (main)
  (write "Hello")
  (newline))

(gtk-webview "Hello world" "https://gnu.org" `((main . ,main)))
