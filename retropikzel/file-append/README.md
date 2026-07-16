Utilites for appending into files


(**with-append-to-file string thunk**)

Works similar to with-output-to-file except appends to the end of the file.
Note that currently the write happens after the thunk finishes!
