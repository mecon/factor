! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations io.backend libc kernel namespaces
sequences system vectors ;
IN: destructors

SYMBOL: error-destructors
SYMBOL: always-destructors

TUPLE: destructor object destroyed? ;

M: destructor dispose
    dup destructor-destroyed? [
        drop
    ] [
        dup destructor-object dispose
        t swap set-destructor-destroyed?
    ] if ;

: <destructor> ( obj -- newobj )
    f destructor construct-boa ;

: add-error-destructor ( obj -- )
    <destructor> error-destructors get push ;

: add-always-destructor ( obj -- )
    <destructor> always-destructors get push ;

: dispose-each ( seq -- )
    <reversed> [ dispose ] each ;

: do-always-destructors ( -- )
    always-destructors get dispose-each ;

: do-error-destructors ( -- )
    error-destructors get dispose-each ;

: with-destructors ( quot -- )
    [
        V{ } clone always-destructors set
        V{ } clone error-destructors set
        [ do-always-destructors ]
        [ do-error-destructors ] cleanup
    ] with-scope ; inline

! Memory allocations
TUPLE: memory-destructor alien ;

C: <memory-destructor> memory-destructor

M: memory-destructor dispose ( obj -- )
    memory-destructor-alien free ;

: free-always ( alien -- )
    <memory-destructor> add-always-destructor ;

: free-later ( alien -- )
    <memory-destructor> add-error-destructor ;

! Handles
TUPLE: handle-destructor alien ;

C: <handle-destructor> handle-destructor

HOOK: destruct-handle io-backend ( obj -- )

M: handle-destructor dispose ( obj -- )
    handle-destructor-alien destruct-handle ;

: close-always ( handle -- )
    <handle-destructor> add-always-destructor ;

: close-later ( handle -- )
    <handle-destructor> add-error-destructor ;

! Sockets
TUPLE: socket-destructor alien ;

C: <socket-destructor> socket-destructor

HOOK: destruct-socket io-backend ( obj -- )

M: socket-destructor dispose ( obj -- )
    socket-destructor-alien destruct-socket ;

: close-socket-always ( handle -- )
    <socket-destructor> add-always-destructor ;

: close-socket-later ( handle -- )
    <socket-destructor> add-error-destructor ;
