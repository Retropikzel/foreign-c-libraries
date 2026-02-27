
(spite-init "Spite Test" 800 800)

(define player-x 100)
(define player-y 100)

(define font-image (load-image "test-resources/charmap-cellphone_black.png"))

(define black '(0 0 0))
(define blue '(0 0 255))

(define character-width 7)
(define character-height 9)
(define draw-width 14)
(define draw-height 18)
(define character-lines (list " !\"#¤%&/()*+,-./01"
                              "23456789:;<=>?@ABC"
                              "DEFGHIJKLMNOPQRSTU"
                              "VWXYZ[\\]^_´abcdefg"
                              "hijklmnopqrstuvwxy"
                              "z{|}~"))
(define font (make-bitmap-font font-image
                               character-width
                               character-height
                               draw-width
                               draw-height
                               character-lines))
(set-bitmap-font font)

(define update
  (lambda (delta-time events)
    (for-each
      (lambda (event)
        (when (symbol=? (cdr (assoc 'type event)) 'key-down)
          (let ((key (cdr (assoc 'key event))))
            (when (string=? key "W") (set! player-y (- player-y 5)))
            (when (string=? key "A") (set! player-x (- player-x 5)))
            (when (string=? key "S") (set! player-y (+ player-y 5)))
            (when (string=? key "D") (set! player-x (+ player-x 5)))
            )))
      events)
    #t))

(define draw
  (lambda ()
    (draw-bitmap-text "Cool beans!" 100 100)
    (apply set-draw-color black)
    (draw-line 50 50 100 100)
    (apply set-draw-color blue)
    (draw-line 150 150 200 200)
    (apply set-draw-color black)
    (draw-rectangle player-x player-y 64 64)
    (fill-rectangle (+ player-x 32) (+ player-y 32) 16 16)
    (draw-triangle 350 350 380 380 330 380)
    ;(fill-triangle 450 450 480 480 430 480)
    ))

(spite-start update draw)
