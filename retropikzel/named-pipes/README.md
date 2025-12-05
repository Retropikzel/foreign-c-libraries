Named pipe library built upon (foreign c).

## Caveats

Does not yet work on Chibi.

## Documentation



(**create-pipe** path mode)

Path is the location you want the pipe to be. mode is filemode as number,
for example 0755.



(**open-input-pipe** path)

Opens input pipe in path and returns it.



(**input-pipe?** object)

Returns #t if given object is input pipe, #f otherwise.



(**open-output-pipe** path)

Opens output pipe in path and returns it.



(**output-pipe?** object)

Returns #t if given object is output pipe, #f otherwise.



(**pipe-read-u8** pipe)

Read u8 byte from given pipe. Errors if pipe is not input pipe.



(**pipe-write-u8** pipe)

Writes u8 byte into given pipe. Errros if pipe is not output pipe.



(**pipe-read-char** pipe)

Read character from given pipe. Errors if pipe is not input pipe.



(**pipe-write-char** pipe)

Write character into given pipe. Errors if pipe is not output pipe.



(**pipe-read-string** count pipe)

Read string of length count or until enf of file from given pipe.  Errors if
pipe is not input pipe.



(**pipe-write-string** text pipe)

Write string text into given pipe. Errors if pipe is not output pipe.



(**pipe-read** pipe)

Read from given pipe. Errors if pipe is not input pipe.



(**pipe-read-line** pipe)

Read line or until end of file from given pipe. Does not block.  Errors if
pipe is not input pipe.



(**close-pipe** pipe)

Closes given pipe.
