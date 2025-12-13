(import (scheme base)
        (scheme write)
        (retropikzel pstk))

(define tk (tk-start))
(define text (tk 'create-widget 'text))
(define open-file #f)

(define (new-button-proc a)
  (let ((dir (tk/choose-directory 'initialdir: "/tmp"
                                  'mustexist: #t)))
                    (display "Directory: ")
                    (write dir)
                    (newline)))
(define new-button
  (tk 'create-widget 'button 'text: "New" 'command: `(,new-button-proc 10)))

(define (open-button-proc)
  (tk/message-box 'message:
                  "Warning! This editor is an example. Do not open any important files with it.")
  (set! open-file (tk/get-open-file 'initialdir: "/tmp")))
(define open-button
  (tk 'create-widget 'button 'text: "Open" 'command: open-button-proc))

(define (save-button-proc)
                  (display "Saving file: ")
                  (write open-file)
                  (newline))
(define save-button
  (tk 'create-widget 'button 'text: "Save" 'command: save-button-proc))

;(tk/pack text new-button open-button save-button 'padx: 20 'pady: 20)
(tk/pack text 'padx: 20 'pady: 20)

(tk/bind 'all
         "<Key>"
         `(,(lambda (k)
              (display "Key code: ")
              (display k)
              (newline)
              (display "Text: ")
              (write (text 'get 1.0 'end))
              (newline)
              #f)
            %k))

(tk-event-loop tk)
