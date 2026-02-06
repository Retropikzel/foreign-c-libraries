
(define response (request 'GET
                          "http://echo-http-requests.appspot.com/echo"
                          '(headers (foo . bar))
                          '(cookies (foo . bar))))

(display "Response")
(newline)

(display "status-code: ")
(write (response-status-code response))
(newline)

(display "bytes: ")
(write (response-bytes response))
(newline)

(display "text: ")
(write (response-text response))
(newline)

(display "headers: ")
(write (response-headers response))
(newline)

(when (not (= (response-status-code response) 200))
  (error "Status code not 200" response))

(define response1 (request 'POST
                          "http://echo-http-requests.appspot.com/echo"
                          '(headers (foo . bar))
                          '(cookies (foo . bar))
                          '(body . "Hello world")))

(display "Response")
(newline)

(display "status-code: ")
(write (response-status-code response1))
(newline)

(display "bytes: ")
(write (response-bytes response1))
(newline)

(display "text: ")
(write (response-text response1))
(newline)

(display "headers: ")
(write (response-headers response1))
(newline)
