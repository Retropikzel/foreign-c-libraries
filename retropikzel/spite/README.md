Game library inspired by some other game library named after emotion built on
top of [(foreign c)](https://sr.ht/~retropikzel/foreign-c/).

Please note that Spite is currently in **alpha** stage.


[Issue tracker](https://todo.sr.ht/~retropikzel/Spite)

[Mailing lists](https://sr.ht/~retropikzel/Spite/lists)

[Source](https://git.sr.ht/~retropikzel/spite)


## Documentation - Spite



(**spite-init** title width height)

This needs to be called first. title is a string you want to be used as
the game window title. width and height are the desired window size.

It will initialize spite, loading SDL2 libraries and such and then opens a
window for you.

The renderer size is set to same size as window size, you can change it with:

    (spite-option-set! 'renderer-size width height)



(**spite-start** update-procedure draw-procedure)

Starts the update and draw loop. Needs to be called for anything to happen.

update-procedure is the procedure which is run in the main loop before the
draw procedure. Where the logic happens. draw-procedure is where you should
do all your drawing.



(**spite-option-set! name . value)

Sets different options of Spite. name is the name of option. value is the
value or values of the option.

Options and possible values:

- allow-window-resizing
    - #t #f
- renderer-size
    - Width and height



(**load-image** path)

Loads image from the path, supported filetypes are same as supported by
SDLimage [https://wiki.libsdl.org/SDL2image/FrontPage](https://wiki.libsdl.org/SDL2image/FrontPage)

Returns an image record. Which can be used with draw-image and
draw-image-slice.



(**image?** object)

Returns #t if object is image, otherwise #f.



(**draw-image** image-index x y width height)

Draws given image of image-index, returned by **load-image**. To position x
and y, left top corner. Size of width and height.



(**draw-image-slice** image-index x y width height slize-x slice-y slice-width slice-height)

Draws given slice of image-index, returned by **load-image**. To position x
and y, left top corner. Size of width and height. Clipped from slice-x
and slice-y (top left corner) of size slice-width slice-height.



(**make-color** r g b . a)

Makes a color record of red(r) green(g) blue(b) and optionally of alpha(a).
If a is not given it defaults to 255.



(**color?** object)

Returns #t of object is color, otherwise #f.



(**color:r** color)

Return red of color.



(**color:r!** color r)

Set the red of color



(**color:g** color)

Return green of color.



(**color:g!** color g)

Set the green of color



(**color:b** color)

Return blue of color.



(**color:b!** color b)

Set the blue of color



(**color:a** color)

Return alpha of color.



(**color:a!** color a)

Set the alpha of color



(**draw-point** x y size color)

Draws a point of size and color on x and y.



(**draw-line** x1 y1 x2 y2 line-size color)

Draws a line from point x1 y1 to x2 y2 with line-size of color.



(**make-event** type data)

Make new event with given type and data.



(**push-event** type data)

Make and push event of given type and data. The type should be a symbol, and
data can be anything.



(**event:type** event)

Returns the type of the event.



(**event:data** event)

Returns the data of event.



(**clear-events!**)

Removes all events in the event queue.



(**make-bitmap-font** image character-width character-height draw-width draw-height characters)



(**draw-bitmap-text** text x y font)



(**draw-polygon** x y polygon)

Draw given polygon at position x y.

