! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib hashtables kernel math math.combinatorics math.parser
    math.ranges project-euler.common sequences sequences.lib sorting ;
IN: project-euler.043

! http://projecteuler.net/index.php?section=problems&id=43

! DESCRIPTION
! -----------

! The number, 1406357289, is a 0 to 9 pandigital number because it is made up
! of each of the digits 0 to 9 in some order, but it also has a rather
! interesting sub-string divisibility property.

! Let d1 be the 1st digit, d2 be the 2nd digit, and so on. In this way, we note
! the following:

!     * d2d3d4  = 406 is divisible by 2
!     * d3d4d5  = 063 is divisible by 3
!     * d4d5d6  = 635 is divisible by 5
!     * d5d6d7  = 357 is divisible by 7
!     * d6d7d8  = 572 is divisible by 11
!     * d7d8d9  = 728 is divisible by 13
!     * d8d9d10 = 289 is divisible by 17

! Find the sum of all 0 to 9 pandigital numbers with this property.


! SOLUTION
! --------

! Brute force generating all the pandigitals then checking 3-digit divisiblity
! properties...this is very slow!

<PRIVATE

: subseq-divisible? ( n index seq -- ? )
    [ 1- dup 3 + ] dip subseq 10 digits>integer swap mod zero? ;

: interesting? ( seq -- ? )
    {
        [ 17 8 pick subseq-divisible? ]
        [ 13 7 pick subseq-divisible? ]
        [ 11 6 pick subseq-divisible? ]
        [ 7 5 pick subseq-divisible? ]
        [ 5 4 pick subseq-divisible? ]
        [ 3 3 pick subseq-divisible? ]
        [ 2 2 pick subseq-divisible? ]
    } && nip ;

PRIVATE>

: euler043 ( -- answer )
    1234567890 number>digits all-permutations
    [ interesting? ] subset [ 10 digits>integer ] map sum ;

! [ euler043 ] time
! 125196 ms run / 19548 ms GC time


! ALTERNATE SOLUTIONS
! -------------------

! Build the number from right to left, generating the next 3-digits according
! to the divisiblity rules and combining them with the previous digits if they
! overlap and still have all unique digits. When done with that, add whatever
! missing digit is needed to make the number pandigital.

<PRIVATE

: candidates ( n -- seq )
    1000 over <range> [ number>digits 3 0 pad-left ] map [ all-unique? ] subset ;

: overlap? ( seq -- ? )
    dup first 2 tail* swap second 2 head = ;

: clean ( seq -- seq )
    [ unclip 1 head prefix concat ] map [ all-unique? ] subset ;

: add-missing-digit ( seq -- seq )
    dup natural-sort 10 seq-diff first prefix ;

: interesting-pandigitals ( -- seq )
    17 candidates { 13 11 7 5 3 2 } [
        candidates swap cartesian-product [ overlap? ] subset clean
    ] each [ add-missing-digit ] map ;

PRIVATE>

: euler043a ( -- answer )
    interesting-pandigitals [ 10 digits>integer ] sigma ;

! [ euler043a ] 100 ave-time
! 19 ms run / 1 ms GC ave time - 100 trials

MAIN: euler043a
