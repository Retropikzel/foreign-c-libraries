(define-library
  (retropikzel spite)
  (import (scheme base)
          (scheme write)
          (scheme complex)
          (scheme process-context)
          (scheme file)
          (scheme load)
          (scheme time)
          (c2foreign-c sdl2 init)
          (c2foreign-c sdl2 video)
          (c2foreign-c sdl2 render)
          (c2foreign-c sdl2 events)
          (c2foreign-c sdl2 keyboard)
          (foreign c))
  (export spite-init
          spite-start
          spite-option-set!

          load-image
          image?
          image-path

          draw-image
          draw-image-slice

          set-draw-color
          draw-point
          draw-line
          draw-rectangle
          fill-rectangle
          draw-triangle
          ;; FIXME
          ;fill-triangle

          push-event
          clear-events!

          make-bitmap-font
          set-bitmap-font
          draw-bitmap-text)
    (include "spite.scm"))
