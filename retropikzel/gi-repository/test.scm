
;(test-begin "gi-repository")
(define-c-library libc '("stdlib.h" "stdio.h" "string.h" "stdio.h") #f ())
(define-c-procedure c-puts libc 'puts 'int '(pointer))

(define gtk (gi-repository "Gtk" "4.0"))
(define gtk-application (gi-object gtk "Gtk" "Application"))
(define gtk-window (gi-object gtk "Gtk" "ApplicationWindow"))

(define gobject (gi-repository "GObject" "2.0"))
(define gobject-object (gi-object gtk "GObject" "Object"))
(define gobject-closure (gi-struct gtk "GObject" "Closure"))

(define gio (gi-repository "Gio" "2.0"))
(define gio-application (gi-object gio "Gio" "Application"))

(define app (gi-object-invoke gtk-application "new" "org.hello.world" 0))

;(display "HERE: method-info ")
;(write (gi-object-method-info gtk-window "new"))
;(newline)

(define-c-callback
  closure-process
  'void
  '(pointer pointer int pointer pointer pointer)
  (lambda (closure return-value n-param-values param-values invocation-hint marshal-data)
    ;(c-puts (string->c-bytevector "HERE IN CLOSURE"))
    (display "HERE: in closure")
    (newline)
    ))
(define closure (gi-struct-invoke gobject-closure "new_simple" 128 closure-process))

(gi-invoke gobject "signal_connect_closure" app "activate" closure 0)
(display "HERE: method-info ")
(write (gi-object-method-info gio-application "run"))
(newline)

(display (gi-object-invoke gio-application "run" 0 (c-bytevector-null)))
(newline)


;|#
;(test-end "gi-repository")
