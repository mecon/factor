USING: arrays kernel math namespaces sequences kernel.private
sequences.private strings sbufs tools.test vectors bit-arrays
generic vocabs.loader ;
IN: sequences.tests

[ V{ 1 2 3 4 } ] [ 1 5 dup <slice> >vector ] unit-test
[ 3 ] [ 1 4 dup <slice> length ] unit-test
[ 2 ] [ 1 3 { 1 2 3 4 } <slice> length ] unit-test
[ V{ 2 3 } ] [ 1 3 { 1 2 3 4 } <slice> >vector ] unit-test
[ V{ 4 5 } ] [ { 1 2 3 4 5 } 2 tail-slice* >vector ] unit-test
[ V{ 3 4 } ] [ 2 4 1 10 dup <slice> subseq >vector ] unit-test
[ V{ 3 4 } ] [ 0 2 2 4 1 10 dup <slice> <slice> subseq >vector ] unit-test
[ "cba" ] [ "abcdef" 3 head-slice reverse ] unit-test

[ 5040 ] [ [ 1 2 3 4 5 6 7 ] 1 [ * ] reduce ] unit-test

[ 5040 [ 1 1 2 6 24 120 720 ] ]
[ [ 1 2 3 4 5 6 7 ] 1 [ * ] accumulate ] unit-test

[ f f ] [ [ ] [ ] find ] unit-test
[ 0 1 ] [ [ 1 ] [ ] find ] unit-test
[ 1 "world" ] [ [ "hello" "world" ] [ "world" = ] find ] unit-test
[ 2 3 ] [ [ 1 2 3 ] [ 2 > ] find ] unit-test
[ f f ] [ [ 1 2 3 ] [ 10 > ] find ] unit-test

[ 1 CHAR: e ]
[ "hello world" "aeiou" [ member? ] curry find ] unit-test

[ 4 CHAR: o ]
[ 3 "hello world" "aeiou" [ member? ] curry find* ] unit-test

[ f         ] [ 3 [ ]     member? ] unit-test
[ f         ] [ 3 [ 1 2 ] member? ] unit-test
[ t ] [ 1 [ 1 2 ] member? ] unit-test
[ t ] [ 2 [ 1 2 ] member? ] unit-test

[ t ]
[ [ "hello" "world" ] [ second ] keep memq? ] unit-test

[ 4 ] [ CHAR: x "tuvwxyz" >vector index ] unit-test

[ f ] [ CHAR: x 5 "tuvwxyz" >vector index* ] unit-test

[ f ] [ CHAR: a 0 "tuvwxyz" >vector index* ] unit-test

[ f ] [ [ "Hello" { } 0.75 ] [ string? ] all? ] unit-test
[ t ] [ [ ] [ ] all? ] unit-test
[ t ] [ [ "hi" t 0.5 ] [ ] all? ] unit-test

[ [ 1 2 3 ] ] [ [ 1 4 2 5 3 6 ] [ 4 < ] subset ] unit-test
[ { 4 2 6 } ] [ { 1 4 2 5 3 6 } [ 2 mod 0 = ] subset ] unit-test

[ [ 3 ] ] [ [ 1 2 3 ] 2 [ swap < ] curry subset ] unit-test

[ "hello world how are you" ]
[ { "hello" "world" "how" "are" "you" } " " join ]
unit-test

[ "" ] [ { } "" join ] unit-test

[ { } ] [ { } flip ] unit-test

[ { "b" "e" } ] [ 1 { { "a" "b" "c" } { "d" "e" "f" } } flip nth ] unit-test

[ { { 1 4 } { 2 5 } { 3 6 } } ]
[ { { 1 2 3 } { 4 5 6 } } flip ] unit-test

[ f ] [ [ { } { } "Hello" ] all-equal? ] unit-test
[ f ] [ [ { 2 } { } { } ] all-equal? ] unit-test
[ t ] [ [ ] all-equal? ] unit-test
[ t ] [ [ 1234 ] all-equal? ] unit-test
[ t ] [ [ 1.0 1 1 ] all-equal? ] unit-test
[ t ] [ { 1 2 3 4 } [ < ] monotonic? ] unit-test
[ f ] [ { 1 2 3 4 } [ > ] monotonic? ] unit-test
[ [ 2 3 4 ] ] [ [ 1 2 3 ] 1 [ + ] curry map ] unit-test

[ 1 ] [ 0 [ 1 2 ] nth ] unit-test
[ 2 ] [ 1 [ 1 2 ] nth ] unit-test

[ [ ]           ] [ [ ]   [ ]       append ] unit-test
[ [ 1 ]         ] [ [ 1 ] [ ]       append ] unit-test
[ [ 2 ]         ] [ [ ] [ 2 ]       append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] [ 4 ] append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] { 4 } append ] unit-test

[ "a" -1 append ] must-fail
[ -1 "a" append ] must-fail

[ [ ]       ] [ 1 [ ]           remove ] unit-test
[ [ ]       ] [ 1 [ 1 ]         remove ] unit-test
[ [ 3 1 1 ] ] [ 2 [ 3 2 1 2 1 ] remove ] unit-test

[ [ ]       ] [ [ ]       reverse ] unit-test
[ [ 1 ]     ] [ [ 1 ]     reverse ] unit-test
[ [ 3 2 1 ] ] [ [ 1 2 3 ] reverse ] unit-test

[ f ] [ f 0 head ] unit-test
[ [ ] ] [ [ 1 ] 0 head ] unit-test
[ [ 1 2 3 ] ] [ [ 1 2 3 4 ] 3 head ] unit-test
[ [ ] ] [ [ 1 2 3 ] 3 tail ] unit-test
[ [ 3 ] ] [ [ 1 2 3 ] 2 tail ] unit-test

[ "blah" ] [ "blahxx" 2 head* ] unit-test

[ "xx" ] [ "blahxx" 2 tail* ] unit-test

[ t ] [ "xxfoo" 2 head-slice "xxbar" 2 head-slice = ] unit-test
[ t ] [ "xxfoo" 2 head-slice "xxbar" 2 head-slice [ hashcode ] bi@ = ] unit-test

[ t ] [ "xxfoo" 2 head-slice SBUF" barxx" 2 tail-slice* = ] unit-test
[ t ] [ "xxfoo" 2 head-slice SBUF" barxx" 2 tail-slice* [ hashcode ] bi@ = ] unit-test

[ t ] [ [ 1 2 3 ] [ 1 2 3 ] sequence= ] unit-test
[ t ] [ [ 1 2 3 ] { 1 2 3 } sequence= ] unit-test
[ t ] [ { 1 2 3 } [ 1 2 3 ] sequence= ] unit-test
[ f ] [ [ ] [ 1 2 3 ] sequence= ] unit-test

[ { 1 3 2 4 } ] [ { 1 2 3 4 } clone 1 2 pick exchange ] unit-test

[ { "" "a" "aa" "aaa" } ]
[ 4 [ CHAR: a <string> ] map ]
unit-test

[ V{ } ] [ "f" V{ } clone [ delete ] keep ] unit-test
[ V{ } ] [ "f" V{ "f" } clone [ delete ] keep ] unit-test
[ V{ } ] [ "f" V{ "f" "f" } clone [ delete ] keep ] unit-test
[ V{ "x" } ] [ "f" V{ "f" "x" "f" } clone [ delete ] keep ] unit-test
[ V{ "y" "x" } ] [ "f" V{ "y" "f" "x" "f" } clone [ delete ] keep ] unit-test

[ V{ 0 1 4 5 } ] [ 6 >vector 2 4 pick delete-slice ] unit-test

[ 6 >vector 2 8 pick delete-slice ] must-fail

[ V{ } ] [ 6 >vector 0 6 pick delete-slice ] unit-test

[ V{ 1 2 "a" "b" 5 6 7 } ] [
    { "a" "b" } 2 4 V{ 1 2 3 4 5 6 7 } clone
    [ replace-slice ] keep
] unit-test

[ V{ 1 2 "a" "b" 6 7 } ] [
    { "a" "b" } 2 5 V{ 1 2 3 4 5 6 7 } clone
    [ replace-slice ] keep
] unit-test

[ V{ 1 2 "a" "b" 4 5 6 7 } ] [
    { "a" "b" } 2 3 V{ 1 2 3 4 5 6 7 } clone
    [ replace-slice ] keep
] unit-test

[ V{ 1 2 3 4 5 6 7 "a" "b" } ] [
    { "a" "b" } 7 7 V{ 1 2 3 4 5 6 7 } clone
    [ replace-slice ] keep
] unit-test

[ V{ "a" 3 } ] [
    { "a" } 0 2 V{ 1 2 3 } clone [ replace-slice ] keep
] unit-test

[ { 1 4 9 } ] [ { 1 2 3 } clone dup [ sq ] change-each ] unit-test

[ 5 ] [ 1 >bignum { 1 5 7 } nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum { 1 5 7 } nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum "\u000001\u000005\u000007" nth-unsafe ] unit-test

[ SBUF" before&after" ] [
    "&" 6 11 SBUF" before and after" [ replace-slice ] keep
] unit-test

[ 3 "a" ] [ { "a" "b" "c" "a" "d" } [ "a" = ] find-last ] unit-test

[ f f ] [ 100 { 1 2 3 } [ 1 = ] find* ] unit-test
[ f f ] [ 100 { 1 2 3 } [ 1 = ] find-last* ] unit-test
[ f f ] [ -1 { 1 2 3 } [ 1 = ] find* ] unit-test

[ 0 ] [ { "a" "b" "c" } { "A" "B" "C" } mismatch ] unit-test

[ 1 ] [ { "a" "b" "c" } { "a" "B" "C" } mismatch ] unit-test

[ f ] [ { "a" "b" "c" } { "a" "b" "c" } mismatch ] unit-test

[ V{ } V{ } ] [ { "a" "b" } { "a" "b" } drop-prefix [ >vector ] bi@ ] unit-test

[ V{ "C" } V{ "c" } ] [ { "a" "b" "C" } { "a" "b" "c" } drop-prefix [ >vector ] bi@ ] unit-test

[ -1 1 "abc" <slice> ] must-fail

[ V{ "a" "b" } V{ } ] [ { "X" "a" "b" } { "X" } drop-prefix [ >vector ] bi@ ] unit-test

[ -1 ] [ "ab" "abc" <=> ] unit-test
[ 1 ] [ "abc" "ab" <=> ] unit-test

[ 1 4 9 16 16 V{ f 1 4 9 16 } ] [
    V{ } clone "cache-test" set
    1 "cache-test" get [ sq ] cache-nth
    2 "cache-test" get [ sq ] cache-nth
    3 "cache-test" get [ sq ] cache-nth
    4 "cache-test" get [ sq ] cache-nth
    4 "cache-test" get [ "wrong" ] cache-nth
    "cache-test" get
] unit-test

[ 1 ] [ 0.5 { 1 2 3 } nth ] unit-test

! Pathological case
[ "ihbye" ] [ "hi" <reversed> "bye" append ] unit-test

[ t ] [ "hi" <reversed> SBUF" hi" <reversed> = ] unit-test

[ t ] [ "hi" <reversed> SBUF" hi" <reversed> = ] unit-test

[ t ] [ "hi" <reversed> SBUF" hi" <reversed> [ hashcode ] bi@ = ] unit-test

[ -10 "hi" "bye" copy ] must-fail
[ 10 "hi" "bye" copy ] must-fail

[ V{ 1 2 3 5 6 } ] [
    3 V{ 1 2 3 4 5 6 } clone [ delete-nth ] keep
] unit-test

[ V{ 1 2 3 } ]
[ 3 V{ 1 2 } clone [ push-new ] keep ] unit-test

[ V{ 1 2 3 } ]
[ 3 V{ 1 3 2 } clone [ push-new ] keep ] unit-test

! Columns
{ { 1 2 3 } { 4 5 6 } { 7 8 9 } } [ clone ] map "seq" set

[ { 1 4 7 } ] [ "seq" get 0 <column> >array ] unit-test
[ ] [ "seq" get 1 <column> [ sq ] change-each ] unit-test
[ { 4 25 64 } ] [ "seq" get 1 <column> >array ] unit-test

! erg's random tester found this one
[ SBUF" 12341234" ] [
    9 <sbuf> dup "1234" swap push-all dup dup swap push-all
] unit-test

[ f ] [ f V{ } like f V{ } like eq? ] unit-test

[ ?{ f t } ] [ 0 2 ?{ f t f } subseq ] unit-test

[ V{ f f f } ] [ 3 V{ } new ] unit-test
[ SBUF" \0\0\0" ] [ 3 SBUF" " new ] unit-test

[ 0 ] [ f length ] unit-test
[ f first ] must-fail
[ 3 ] [ 3 10 nth ] unit-test
[ 3 ] [ 3 10 nth-unsafe ] unit-test
[ -3 10 nth ] must-fail
[ 11 10 nth ] must-fail

[ -1./0. 0 delete-nth ] must-fail
[ "" ] [ "" [ CHAR: \s = ] trim ] unit-test
[ "" ] [ "" [ CHAR: \s = ] left-trim ] unit-test
[ "" ] [ "" [ CHAR: \s = ] right-trim ] unit-test
[ "" ] [ "  " [ CHAR: \s = ] left-trim ] unit-test
[ "" ] [ "  " [ CHAR: \s = ] right-trim ] unit-test
[ "asdf" ] [ " asdf " [ CHAR: \s = ] trim ] unit-test
[ "asdf " ] [ " asdf " [ CHAR: \s = ] left-trim ] unit-test
[ " asdf" ] [ " asdf " [ CHAR: \s = ] right-trim ] unit-test

! Hardcore
[ ] [ "sequences" reload ] unit-test
