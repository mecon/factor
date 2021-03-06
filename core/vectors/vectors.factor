! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences sequences.private growable ;
IN: vectors

<PRIVATE

: array>vector ( array length -- vector )
    vector construct-boa ; inline

PRIVATE>

: <vector> ( n -- vector ) f <array> 0 array>vector ; inline

: >vector ( seq -- vector ) V{ } clone-like ;

M: vector like
    drop dup vector? [
        dup array? [ dup length array>vector ] [ >vector ] if
    ] unless ;

M: vector new drop [ f <array> ] keep >fixnum array>vector ;

M: vector equal?
    over vector? [ sequence= ] [ 2drop f ] if ;

M: sequence new-resizable drop <vector> ;

INSTANCE: vector growable

: 1vector ( x -- vector ) 1array >vector ;

: ?push ( elt seq/f -- seq )
    [ 1 <vector> ] unless* [ push ] keep ;
