(define spite-inited? #f)
(define started? #f)
(define exit? #f)
(define scale-x 1.0)
(define scale-y 1.0)
(define events '())
(define current-bitmap-font #f)
(define current-line-size 1)
(define draw-color-r 0)
(define draw-color-g 0)
(define draw-color-b 0)
(define draw-color-a 255)
(define-c-library sdl2*
                  '("SDL2/SDL.h")
                  "SDL2-2.0"
                  `((additional-paths ("retropikzel/spite"
                                       "snow/retropikzel/spite"))
                    (additional-versions ("0"))))
(define-c-library sdl2-image*
                  '("SDL2/SDL_image.h")
                  "SDL2_image-2.0"
                  `((additional-paths ("retropikzel/spite"
                                       "snow/retropikzel/spite"))
                    (additional-versions ("0"))))

(define-c-procedure sdl-init sdl2* 'SDL_Init 'int '(int))
(define-c-procedure sdl-get-window-flags sdl2* 'SDL_GetWindowFlags 'int '(pointer))
(define-c-procedure sdl-create-window sdl2* 'SDL_CreateWindow 'pointer '(pointer int int int int int))
(define-c-procedure sdl-create-renderer sdl2* 'SDL_CreateRenderer 'pointer '(pointer int int))
(define-c-procedure sdl-render-setlogial-size sdl2* 'SDL_RenderSetLogicalSize 'int '(pointer int int))
(define-c-procedure sdl-render-set-integer-scale sdl2* 'SDL_RenderSetIntegerScale 'int '(pointer int))
(define-c-procedure sdl-set-render-draw-color sdl2* 'SDL_SetRenderDrawColor 'int '(pointer int int int int))
(define-c-procedure sdl-render-clear sdl2* 'SDL_RenderClear 'int '(pointer))
(define-c-procedure sdl-render-present sdl2* 'SDL_RenderPresent 'void '(pointer))
(define-c-procedure sdl-get-key-from-scancode sdl2* 'SDL_GetKeyFromScancode 'int '(int))
(define-c-procedure sdl-get-key-name sdl2* 'SDL_GetKeyName 'pointer '(int))
(define-c-procedure sdl-poll-event sdl2* 'SDL_PollEvent 'int '(pointer))
(define-c-procedure sdl-img-load-texture sdl2-image* 'IMG_LoadTexture 'pointer '(pointer pointer))
(define-c-procedure sdl-render-copy sdl2* 'SDL_RenderCopy 'int '(pointer pointer pointer pointer))
(define-c-procedure sdl-render-draw-line sdl2* 'SDL_RenderDrawLine 'int '(pointer int int int int))
(define-c-procedure sdl-render-draw-rect sdl2* 'SDL_RenderDrawRect 'int '(pointer pointer))
(define-c-procedure sdl-render-fill-rect sdl2* 'SDL_RenderFillRect 'int '(pointer pointer))
(define-c-procedure sdl-render-set-scale sdl2* 'SDL_RenderSetScale 'int '(pointer float float))
(define-c-procedure sdl-create-texture-from-surface sdl2* 'SDL_CreateTextureFromSurface 'pointer '(pointer pointer))
(define-c-procedure sdl-set-window-resizable sdl2* 'SDL_SetWindowResizable 'void '(pointer int))
(define-c-procedure sdl-render-get-scale sdl2* 'SDL_RenderGetScale 'void '(pointer pointer pointer))
(define-c-procedure sdl-render-geometry sdl2* 'SDL_RenderGeometry 'void '(pointer pointer pointer int pointer int))

(define window* #f)
(define renderer* #f)
(define event* (make-c-bytevector 4000))
(define draw-rect* (make-c-bytevector (* (c-type-size 'int) 4)))
(define draw-slice-rect* (make-c-bytevector (* (c-type-size 'int) 4)))
(define fill-triangle-vertex-size (+ (* (c-type-size 'int) 6) (* (c-type-size 'float) 2)))
(define fill-triangle-vertex1* (make-c-bytevector fill-triangle-vertex-size 0))
(define fill-triangle-vertex2* (make-c-bytevector fill-triangle-vertex-size 0))
(define fill-triangle-vertex3* (make-c-bytevector fill-triangle-vertex-size 0))
(define fill-triangle-vertexes* (make-c-bytevector (* fill-triangle-vertex-size 3 0)))
(c-bytevector-set!
  fill-triangle-vertexes* 'pointer (* fill-triangle-vertex-size 0) fill-triangle-vertex1*)
(c-bytevector-set!
  fill-triangle-vertexes* 'pointer (* fill-triangle-vertex-size 1) fill-triangle-vertex2*)
(c-bytevector-set!
  fill-triangle-vertexes* 'pointer (* fill-triangle-vertex-size 2) fill-triangle-vertex3*)

(define main-loop-start-time 0)
(define delta-time 0)
(define (main-loop update-procedure draw-procedure)
  (set! main-loop-start-time (current-jiffy))
  (sdl2-events-get)
  (update-procedure delta-time (poll-events!))
  (render-clear)
  (draw-procedure)
  (render-present)
  (set! delta-time (/ (- (current-jiffy) main-loop-start-time) (jiffies-per-second)))
  (unless exit? (main-loop update-procedure draw-procedure)))

(define sdl2-event->spite-event
  (lambda (event)
    (let ((type (c-bytevector-ref event 'int 0)))
      (cond
        ((= type 256)
         (let ((type 'quit))
           (list (cons 'type type))))
        ((or (= type 768) (= type 769))
         (let*
           ((type (if (= type 768) 'key-down 'key-up))
            (scancode (c-bytevector-ref event
                                        'int
                                        (+ (* (c-type-size 'int) 3)
                                           (* (c-type-size 'u8) 4))))
            (keycode (sdl-get-key-from-scancode scancode))
            (key (c-bytevector->string (sdl-get-key-name keycode)))
            (repeat? (= (c-bytevector-ref
                          event
                          'u8
                          (+ (* (c-type-size 'int) 3)
                             (c-type-size 'u8)))
                        1)))
           (list (cons 'type type)
                 (cons 'key key)
                 (cons 'scancode scancode)
                 (cons 'repeat? repeat?))))
        ((= type 1024)
         (let ((type 'mouse-motion)
               (x (c-bytevector-ref event
                                    'int
                                    (+ (* (c-type-size 'int) 5))
                                    ))
               (y (c-bytevector-ref event
                                    'int
                                    (+ (* (c-type-size 'int) 6)))))
           (list (cons 'type type)
                 (cons 'x x)
                 (cons 'y y))))
        ((or (= type 1025) (= type 1026))
         (let ((type (if (= type 1025) 'mouse-button-down 'mouse-button-up))
               (x (c-bytevector-ref event
                                    'int
                                    (+ (* (c-type-size 'int) 4)
                                       (* (c-type-size 'u8) 4))))
               (y (c-bytevector-ref event
                                    'int
                                    (+ (* (c-type-size 'int) 4)
                                       (* (c-type-size 'u8) 4)
                                       (c-type-size 'int))))
               (button (c-bytevector-ref event
                                         'int
                                         (+ (* (c-type-size 'u32) 4))))
               (clicks (c-bytevector-ref event
                                         'int
                                         (+ (* (c-type-size 'u32) 4)
                                            (* (c-type-size 'u8) 2)))))
           (list (cons 'type type)
                 (cons 'x x)
                 (cons 'y y)
                 (cons 'button button)
                 (cons 'clicks clicks))))
        (else
          (list (cons 'type 'sdl2-event)
                (cons 'sdl2-type-number type)))))))

(define sdl2-events-get
  (lambda ()
    (let ((poll-result (sdl-poll-event event*)))
      (cond
        ((= poll-result 1)
         (let ((event (sdl2-event->spite-event event*)))

           (cond ((equal? (cdr (assoc 'type event)) 'quit) (set! exit? #t)))
           (push-event event)
           (sdl2-events-get)))))))

(define render-clear
  (lambda ()
    (sdl-set-render-draw-color renderer* 255 255 255 255)
    (sdl-render-clear renderer*)))

(define render-present
  (lambda ()
    (sdl-render-present renderer*)))

(define-record-type image
  (make-image pointer path)
  image?
  (pointer image-pointer)
  (path image-path))

(define load-image
  (lambda (path)
    (when (not spite-inited?) (error "Can not load images until spite is inited." path))
    (when (not (string? path)) (error "Load path must be string" path))
    (when (not (file-exists? path)) (error (string-append "Could not load image, no such file: " path)))
    (make-image (sdl-img-load-texture renderer* (string->c-bytevector path)) path)))

(define draw-image
  (lambda (image x y width height)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 0) x)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 1) y)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 2) width)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 3) height)
    (sdl-render-copy renderer* (image-pointer image) (c-bytevector-null) draw-rect*)))

(define draw-image-slice
  (lambda (image x y width height slice-x slice-y slice-width slice-height)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 0) x)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 1) y)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 2) width)
    (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 3) height)
    (c-bytevector-set! draw-slice-rect* 'int (* (c-type-size 'int) 0) slice-x)
    (c-bytevector-set! draw-slice-rect* 'int (* (c-type-size 'int) 1) slice-y)
    (c-bytevector-set! draw-slice-rect* 'int (* (c-type-size 'int) 2) slice-width)
    (c-bytevector-set! draw-slice-rect* 'int (* (c-type-size 'int) 3) slice-height)
    (sdl-render-copy renderer* (image-pointer image) draw-slice-rect* draw-rect*)))

(define (set-draw-color r g b . a)
  (set! draw-color-r r)
  (set! draw-color-g g)
  (set! draw-color-b b)
  (set! draw-color-a (if (null? a) 255 a))

  (c-bytevector-set! fill-triangle-vertex1* 'int (* (c-type-size 'int) 2) draw-color-r)
  (c-bytevector-set! fill-triangle-vertex1* 'int (* (c-type-size 'int) 3) draw-color-g)
  (c-bytevector-set! fill-triangle-vertex1* 'int (* (c-type-size 'int) 4) draw-color-b)
  (c-bytevector-set! fill-triangle-vertex1* 'int (* (c-type-size 'int) 5) draw-color-b)

  (c-bytevector-set! fill-triangle-vertex2* 'int (* (c-type-size 'int) 2) draw-color-r)
  (c-bytevector-set! fill-triangle-vertex2* 'int (* (c-type-size 'int) 3) draw-color-g)
  (c-bytevector-set! fill-triangle-vertex2* 'int (* (c-type-size 'int) 4) draw-color-b)
  (c-bytevector-set! fill-triangle-vertex2* 'int (* (c-type-size 'int) 5) draw-color-b)

  (c-bytevector-set! fill-triangle-vertex3* 'int (* (c-type-size 'int) 2) draw-color-r)
  (c-bytevector-set! fill-triangle-vertex3* 'int (* (c-type-size 'int) 3) draw-color-g)
  (c-bytevector-set! fill-triangle-vertex3* 'int (* (c-type-size 'int) 4) draw-color-b)
  (c-bytevector-set! fill-triangle-vertex3* 'int (* (c-type-size 'int) 5) draw-color-b)

  (sdl-set-render-draw-color renderer* r g b draw-color-a))

(define (set-line-size size)
  (set! current-line-size size)
  (sdl-render-set-scale renderer* (inexact (/ size 1)) (inexact (/ size 1))))

(define (draw-point x y)
  (sdl-render-draw-line renderer*
                        (exact (round (/ x current-line-size)))
                        (exact (round (/ y current-line-size)))
                        (exact (round (/ x current-line-size)))
                        (exact (round (/ y current-line-size)))))

(define (draw-line x1 y1 x2 y2)
  (sdl-render-draw-line renderer*
                        (exact (round (/ x1 current-line-size)))
                        (exact (round (/ y1 current-line-size)))
                        (exact (round (/ x2 current-line-size)))
                        (exact (round (/ y2 current-line-size)))))

(define (draw-rectangle x y width height)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 0) x)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 1) y)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 2) width)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 3) height)
  (sdl-render-draw-rect renderer* draw-rect*))

(define (fill-rectangle x y width height)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 0) x)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 1) y)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 2) width)
  (c-bytevector-set! draw-rect* 'int (* (c-type-size 'int) 3) height)
  (sdl-render-fill-rect renderer* draw-rect*))

(define (draw-triangle x1 y1 x2 y2 x3 y3)
  (draw-line x1 y1 x2 y2)
  (draw-line x2 y2 x3 y3)
  (draw-line x3 y3 x1 y1))

;; FIXME
#;(define (fill-triangle x1 y1 x2 y2 x3 y3)
(c-bytevector-set! fill-triangle-vertex1* 'int (* (c-type-size 'int) 0) x1)
(c-bytevector-set! fill-triangle-vertex1* 'int (* (c-type-size 'int) 1) y1)

(c-bytevector-set! fill-triangle-vertex2* 'int (* (c-type-size 'int) 0) x2)
(c-bytevector-set! fill-triangle-vertex2* 'int (* (c-type-size 'int) 1) y2)

(c-bytevector-set! fill-triangle-vertex3* 'int (* (c-type-size 'int) 0) x3)
(c-bytevector-set! fill-triangle-vertex3* 'int (* (c-type-size 'int) 1) y3)

(sdl-render-geometry renderer* (c-bytevector-null) fill-triangle-vertexes* 3 (c-bytevector-null) 0))

(define (spite-option-set! name . value)
  (cond
    ((equal? name 'allow-window-resizing)
     (cond
       ((equal? value '(#t))
        (sdl-set-window-resizable window* 1))
       ((equal? value '(#f))
        (sdl-set-window-resizable window* 0))
       (else (error "Wrong option value for 'allow-window-resizing, must be #t or #f"
                    value))))
    ((equal? name 'renderer-size)
     (if (and (= (length value) 2)
              (number? (car value))
              (number? (cadr value)))
       (sdl-render-setlogial-size renderer* (car value) (cadr value))
       (error "Wrong option value for renderer-size, must be two numbers")))
    (else (error "No such option!" name))))

;; TODO Move to options, add spite-option-get
(define spite-renderer-scale-get
  (lambda ()
    (let ((x (make-c-bytevector (c-type-size 'float)))
          (y (make-c-bytevector (c-type-size 'float))))
      (sdl-render-get-scale renderer* x y)
      (list (cons 'x (c-bytevector-ref x 'float 0))
            (cons 'y (c-bytevector-ref y 'float 0))))))

(define spite-start
  (lambda (update-procedure draw-procedure)
    (cond
      ((not started?)
       (set! started? #t)
       (main-loop update-procedure draw-procedure)))))

(define spite-init
  (lambda (title width height)
    (cond
      ((not started?)
       (sdl-init 32)
       (set! window* (sdl-create-window (string->c-bytevector title) 0 0 width height 4))
       (set! renderer* (sdl-create-renderer window* -1 2))
       (sdl-render-setlogial-size renderer* width height)
       (sdl-render-set-integer-scale renderer* 1)
       (render-clear)
       (render-present)
       (set! spite-inited? #t)))))

(define poll-events!
  (lambda ()
    (let ((events-copy (list-copy events)))
      (set! events (list))
      events-copy)))

(define wait-for-event!
  (lambda ()
    (if (not (= (length events) 0))
      (poll-events!)
      (wait-for-event!))))

(define push-event
  (lambda (event)
    (set! events (append events (list event)))))

(define clear-events!
  (lambda ()
    (set! events (list))))

(define-record-type bitmap-font
  (internal-make-bitmap-font data)
  bitmap-font?
  (data bitmap-font-data))

(define (bitmap-font-get key bitmap)
  (cdr (assoc key (bitmap-font-data bitmap))))

(define-record-type bitmap-char
  (make-bitmap-char char x y)
  bitmap-char?
  (char bitmap-char-char)
  (x bitmap-char-x)
  (y bitmap-char-y))

(define (make-bitmap-font image character-width character-height draw-width draw-height character-lines)
  (let* ((line-items-count (string-length (car character-lines)))
         (characters (apply string-append character-lines))
         (index -1)
         (character-indexes (list))
         (character-positions
           (map (lambda (character)
                  (set! index (+ index 1))
                  (set! character-indexes (append character-indexes (list character index)))
                  (list character
                        (* (modulo index line-items-count)
                           character-width)
                        (* (floor (/ index line-items-count))
                           character-height)))
                (string->list characters))))
    (internal-make-bitmap-font
      `((image . ,image)
        (character-width . ,character-width)
        (character-height . ,character-height)
        (character-draw-width . ,draw-width)
        (character-draw-height . ,draw-height)
        (line-items-count . ,line-items-count)
        (characters . ,characters)
        (character-indexes . ,character-indexes)
        (character-positions . ,character-positions)))))

(define (set-bitmap-font font)
  (set! current-bitmap-font font))

(define (make-bitmap-text text font)
  (map
    (lambda (c)
      (make-bitmap-char
        c
        (cadr (assq c (bitmap-font-get 'character-positions font)))
        (cadr (cdr (assq c (bitmap-font-get 'character-positions font))))))
    (string->list text)))


(define draw-bitmap-text
  (lambda (text x y)
    (when (not current-bitmap-font)
      (error "Current bitmap font not set, use make-bitmap-font and set-bitmap-font"))
    (let ((offset-x x))
      (for-each
        (lambda (bitmap-char)
          (draw-image-slice (bitmap-font-get 'image current-bitmap-font)
                            offset-x
                            y
                            (bitmap-font-get 'character-draw-width current-bitmap-font)
                            (bitmap-font-get 'character-draw-height current-bitmap-font)
                            (bitmap-char-x bitmap-char)
                            (bitmap-char-y bitmap-char)
                            (bitmap-font-get 'character-width current-bitmap-font)
                            (bitmap-font-get 'character-height current-bitmap-font))
          (set! offset-x (+ offset-x (bitmap-font-get 'character-draw-width current-bitmap-font))))
        (make-bitmap-text text current-bitmap-font)))))

