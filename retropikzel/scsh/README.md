scsh - The Scheme Shell

This is an implementation of [scsh](https://scsh.net/) on top of
[(foreign c)](https://codeberg.org/foreign-c/foreign-c). It is not a port but
remake, trying to conform to the scsh as much as is possible but sane.


Not everything is implemented yet, see scsh.sld for commented out exports.

Currently only supports Linux.


## Documentation

See [https://scsh.net/docu/html/man-Z-H-13.html#node_index_start](https://scsh.net/docu/html/man-Z-H-13.html#node_index_start)


## Differences

Since the scsh proper is a program that you give source file to run to, and
this is a library. This version does not include everything. You should be able
to use other libraries to replace most things from scsh proper that this
library does not implement.

### alist->env, env->alist

For some reason the manual says that alist->env modifies the environment, yet
the scsh code does not. So this it returns a list of strings. Similarily
env->alist takes string as argument and returns alist instead of writing to env.
Check tests for examples.

### process-sleep

Same as sleep except instead of milliseconds uses seconds.


### No SRFI's by default

SRFI's that come with scsh proper are not included. See snow-fort or your
Scheme implementation for them.


### No scsh specifics

Not very usefull for library implementation or not possible to do.

- bin-dir
- prefix
- exec-prefix
- lib-dir
- include-dir
- man-dir
- cflags
- clean-up-cres
- compiler-flags
- cppflags
- default-lib-dirs
- define-record
- defs
- dump-scsh
- dump-scsh-program
- find-library-file
- ldflags
- lib-dirs
- lib-dirs-list
- libs
- linker-flags
- open-file


### No sockets

Since this implementation of scsh is library you can get them as library elsewhere.

- accept-connection
- bind-listen-accept-loop
- bind-prepare-listen-accept-loop
- bind-socket
- close-socket
- connect-socket
- connect-socket-no-wait
- connect-socket-successful?
- create-socket
- create-socket-pair
- file-info-socket?
- file-socket?
- host-info
- internet-address->socket-address
- listen-socket
- network-info
- port->socket
- receive-message
- receive-message!
- receive-message!/partial
- receive-message/partial


### No threads

Since this implementation of scsh is library you can get them as library elsewhere.

- current-thread

### No buffered io

- bufpol/block
- bufpol/line
- bufpol/none


### No date/time

Since this implementation of scsh is library you can get them as library elsewhere.

- date
- date->string
- format-date
- make-date


### No string utilities

Since this implementation of scsh is library you can get them as library elsewhere.

- join-strings
