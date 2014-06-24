! Copyright (C) 2004, 2005 Mackenzie Straight.
! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.buffers
USING: alien alien.accessors alien.c-types alien.syntax kernel
kernel.private libc math sequences byte-arrays strings hints
accessors ;

TUPLE: buffer size ptr fill pos ;

: <buffer> ( n -- buffer )
    dup malloc 0 0 buffer construct-boa ;

: buffer-free ( buffer -- )
    dup buffer-ptr free  f swap set-buffer-ptr ;

: buffer-reset ( n buffer -- )
    0 swap { set-buffer-fill set-buffer-pos } set-slots ;

: buffer-consume ( n buffer -- )
    [ buffer-pos + ] keep
    [ buffer-fill min ] keep
    [ set-buffer-pos ] keep
    dup buffer-pos over buffer-fill >= [
        0 over set-buffer-pos
        0 over set-buffer-fill
    ] when drop ;

: buffer@ ( buffer -- alien )
    dup buffer-pos swap buffer-ptr <displaced-alien> ;

: buffer-end ( buffer -- alien )
    dup buffer-fill swap buffer-ptr <displaced-alien> ;

: buffer-peek ( buffer -- byte )
    buffer@ 0 alien-unsigned-1 ;

: buffer-pop ( buffer -- byte )
    dup buffer-peek 1 rot buffer-consume ;

: (buffer-read) ( n buffer -- byte-array )
    [ [ fill>> ] [ pos>> ] bi - min ] keep
    buffer@ swap memory>byte-array ;

: buffer-read ( n buffer -- byte-array )
    [ (buffer-read) ] [ buffer-consume ] 2bi ;

: buffer-length ( buffer -- n )
    [ fill>> ] [ pos>> ] bi - ;

: buffer-capacity ( buffer -- n )
    [ size>> ] [ fill>> ] bi - ;

: buffer-empty? ( buffer -- ? )
    fill>> zero? ;

: extend-buffer ( n buffer -- )
    2dup buffer-ptr swap realloc
    over set-buffer-ptr set-buffer-size ;

: check-overflow ( n buffer -- )
    2dup buffer-capacity > [ extend-buffer ] [ 2drop ] if ;

: >buffer ( byte-array buffer -- )
    over length over check-overflow
    [ buffer-end byte-array>memory ] 2keep
    [ buffer-fill swap length + ] keep set-buffer-fill ;

: byte>buffer ( byte buffer -- )
    1 over check-overflow
    [ buffer-end 0 set-alien-unsigned-1 ] keep
    [ 1+ ] change-fill drop ;

: n>buffer ( n buffer -- )
    [ buffer-fill + ] keep
    [ buffer-size > [ "Buffer overflow" throw ] when ] 2keep
    set-buffer-fill ;
