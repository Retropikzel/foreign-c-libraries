## Arenas

Arena is static or growing size of memory which can be use to allocate
c-bytevectors and then free them all at once. All memory allocated in arenas
is zeroed by default.

(**make-arena** [options])

Creates and returns a new arena. Options is list of pairs.

Options:

  - (size . N)
    - If the size argument is given, that much memory is allocated up front.
  - (fixed? . #t/#f)
    - #f means the arena grows automatically on allocation, #t means it does not
    and any allocation that would go over arena size will throw an error.
    - If #t and size is not given error will thrown

(**arena?** obj)

Returns #t if obj is arena, #f otherwise.

(**call-with-arena** arena thunk)

Call thunk with given arena as first argument. After the thunk returns arena
is freed. If the thunk does not return, for example error occurs, the arena is
not freed.


(**arena-allocate** arena size)

Allocate c-bytevector of given size from the given arena and return it. If
allocation fails, error is signaled.


(**free-arena** arena)

Free the whole arena.
