Library to run shell commands and get their output


(**shell** cmd)

Run given cmd string and return output as string.


(**shell->list** cmd)

Run given cmd string and return output as list of lines.


(**shell->sexp** cmd)

Run given cmd string and return output as sexp using read.


(**shell-exit-code**)

Returns exit code of previous command that was run.
