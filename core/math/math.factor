! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.private ;
IN: math

GENERIC: >fixnum ( x -- y ) foldable
GENERIC: >bignum ( x -- y ) foldable
GENERIC: >integer ( x -- y ) foldable
GENERIC: >float ( x -- y ) foldable

MATH: number= ( x y -- ? ) foldable

M: object number= 2drop f ;

MATH: <  ( x y -- ? ) foldable
MATH: <= ( x y -- ? ) foldable
MATH: >  ( x y -- ? ) foldable
MATH: >= ( x y -- ? ) foldable

: after? ( obj1 obj2 -- ? ) <=> 0 > ; inline
: before? ( obj1 obj2 -- ? ) <=> 0 < ; inline
: after=? ( obj1 obj2 -- ? ) <=> 0 >= ; inline
: before=? ( obj1 obj2 -- ? ) <=> 0 <= ; inline

MATH: +   ( x y -- z ) foldable
MATH: -   ( x y -- z ) foldable
MATH: *   ( x y -- z ) foldable
MATH: /   ( x y -- z ) foldable
MATH: /i  ( x y -- z ) foldable
MATH: mod ( x y -- z ) foldable

MATH: /mod ( x y -- z w ) foldable

MATH: bitand ( x y -- z ) foldable
MATH: bitor  ( x y -- z ) foldable
MATH: bitxor ( x y -- z ) foldable
GENERIC# shift 1 ( x n -- y ) foldable
GENERIC: bitnot ( x -- y ) foldable
GENERIC# bit? 1 ( x n -- ? ) foldable

<PRIVATE

GENERIC: (log2) ( x -- n ) foldable

PRIVATE>

: log2 ( x -- n )
    dup 0 <= [
        "log2 expects positive inputs" throw
    ] [
        (log2)
    ] if ; foldable

GENERIC: zero? ( x -- ? ) foldable

M: object zero? drop f ;

: 1+ ( x -- y ) 1 + ; foldable
: 1- ( x -- y ) 1 - ; foldable
: 2/ ( x -- y ) -1 shift ; foldable
: sq ( x -- y ) dup * ; foldable
: neg ( x -- -x ) 0 swap - ; foldable
: recip ( x -- y ) 1 swap / ; foldable

: /f  ( x y -- z ) >r >float r> >float float/f ; inline

: max ( x y -- z ) [ > ] most ; foldable
: min ( x y -- z ) [ < ] most ; foldable

: between? ( x y z -- ? )
    pick >= [ >= ] [ 2drop f ] if ; inline

: rem ( x y -- z ) tuck mod over + swap mod ; foldable

: sgn ( x -- n ) dup 0 < -1 0 ? swap 0 > 1 0 ? bitor ; foldable

: [-] ( x y -- z ) - 0 max ; inline

: 2^ ( n -- 2^n ) 1 swap shift ; inline

: even? ( n -- ? ) 1 bitand zero? ;

: odd? ( n -- ? ) 1 bitand 1 number= ;

UNION: integer fixnum bignum ;

UNION: rational integer ratio ;

UNION: real rational float ;

UNION: number real complex ;

M: number equal? number= ;

M: real hashcode* nip >fixnum ;

M: real <=> - ;

! real and sequence overlap. we disambiguate:
M: integer hashcode* nip >fixnum ;

M: integer <=> - ;

GENERIC: fp-nan? ( x -- ? )

M: object fp-nan?
    drop f ;

M: float fp-nan?
    double>bits -51 shift BIN: 111111111111 [ bitand ] keep
    number= ;

: (next-power-of-2) ( i n -- n )
    2dup >= [
        drop
    ] [
        >r 1 shift r> (next-power-of-2)
    ] if ;

: next-power-of-2 ( m -- n ) 2 swap (next-power-of-2) ; foldable

: align ( m w -- n ) 1- [ + ] keep bitnot bitand ; inline

<PRIVATE

: iterate-prep 0 -rot ; inline

: if-iterate? >r >r 2over < r> r> if ; inline

: iterate-step ( i n quot -- i n quot )
    #! Apply quot to i, keep i and quot, hide n.
    swap >r 2dup 2slip r> swap ; inline

: iterate-next >r >r 1+ r> r> ; inline

PRIVATE>

: (each-integer) ( i n quot -- )
    [ iterate-step iterate-next (each-integer) ]
    [ 3drop ] if-iterate? ; inline

: (find-integer) ( i n quot -- i )
    [
        iterate-step roll
        [ 2drop ] [ iterate-next (find-integer) ] if
    ] [ 3drop f ] if-iterate? ; inline

: (all-integers?) ( i n quot -- ? )
    [
        iterate-step roll
        [ iterate-next (all-integers?) ] [ 3drop f ] if
    ] [ 3drop t ] if-iterate? ; inline

: each-integer ( n quot -- )
    iterate-prep (each-integer) ; inline

: times ( n quot -- )
    [ drop ] swap compose each-integer ; inline

: find-integer ( n quot -- i )
    iterate-prep (find-integer) ; inline

: all-integers? ( n quot -- ? )
    iterate-prep (all-integers?) ; inline

: find-last-integer ( n quot -- i )
    over 0 < [
        2drop f
    ] [
        2dup 2slip rot [
            drop
        ] [
            >r 1- r> find-last-integer
        ] if
    ] if ; inline
