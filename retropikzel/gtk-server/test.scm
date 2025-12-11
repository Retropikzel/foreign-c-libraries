(import (scheme base)
        (scheme write)
        (scheme process-context)
        (retropikzel system)
        (retropikzel named-pipes)
        (retropikzel gtk-server))

(gtk-server-start "/tmp/scheme-gtkserver.log")

(define gtk-server-version (gtk "gtk_server_version"))
(display gtk-server-version)
(newline)

(gtk "gtk_init NULL NULL")
(define window (gtk "gtk_window_new 0"))
(gtk (string-append "gtk_window_set_title " window " 'Scheme gtk-server test'"))
(gtk (string-append "gtk_window_set_default_size " window " 400 200"))
(gtk (string-append "gtk_window_set_position " window " 1"))

(define button (gtk "gtk_button_new_with_label 'Click to Quit'"))

(define table (gtk "gtk_table_new 10 10 1"))
(gtk (string-append "gtk_table_attach_defaults " table " " button " 5 9 7 9"))

(define entry (gtk "gtk_entry_new"))
(gtk (string-append "gtk_table_attach_defaults " table " " entry " 1 6 3 4"))
(gtk (string-append "gtk_container_add " window " " table))


(gtk (string-append "gtk_widget_show_all " window))

(define (main event)
  (when (not (string=? event "0"))
    (display "Event: ")
    (display event)
    (newline)
    (when (string=? entry event)
      (display "You wrote: ")
      (display (gtk (string-append "gtk_entry_get_text " entry)))
      (newline))
    (when (string=? button event) (exit 0)))
  (gtk "gtk_main_iteration")
  (main (gtk "gtk_server_callback WAIT")))

(gtk "gtk_main_iteration")
(main (gtk "gtk_server_callback 0"))
(gtk "gtk_server_exit")
