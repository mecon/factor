USING: delegate kernel arrays tools.test words math definitions
compiler.units parser generic prettyprint io.streams.string ;
IN: delegate.tests

DEFER: example
[ 1 ] [ \ example 1 "prop" set-word-prop \ example "prop" word-prop ] unit-test
[ ] [ \ example "prop" [ 1+ ] change-word-prop ] unit-test
[ 2 ] [ \ example "prop" word-prop ] unit-test

TUPLE: hello this that ;
C: <hello> hello

TUPLE: goodbye these those ;
C: <goodbye> goodbye

GENERIC: foo ( x -- y )
GENERIC: bar ( a -- b )
GENERIC# whoa 1 ( s t -- w )
PROTOCOL: baz foo { bar 0 } { whoa 1 } ;

: hello-test ( hello/goodbye -- array )
    [ hello? ] [ hello-this ] [ hello-that ] tri 3array ;

CONSULT: baz goodbye goodbye-these ;
M: hello foo hello-this ;
M: hello bar hello-test ;
M: hello whoa >r hello-this r> + ;

GENERIC: bing ( c -- d )
PROTOCOL: bee bing ;
CONSULT: hello goodbye goodbye-those ;
M: hello bing hello-test ;
MIMIC: bee goodbye hello

[ 1 { t 1 0 } ] [ 1 0 <hello> [ foo ] [ bar ] bi ] unit-test
[ { t 1 0 } ] [ 1 0 <hello> bing ] unit-test
[ 1 ] [ 1 0 <hello> f <goodbye> foo ] unit-test
[ { t 1 0 } ] [ 1 0 <hello> f <goodbye> bar ] unit-test
! [ { f 1 0 } ] [ f 1 0 <hello> <goodbye> bing ] unit-test
[ 3 ] [ 1 0 <hello> 2 whoa ] unit-test
[ 3 ] [ 1 0 <hello> f <goodbye> 2 whoa ] unit-test

[ ] [ 10 [ "USE: delegate IN: delegate.tests CONSULT: baz goodbye goodbye-these ;" eval ] times ] unit-test
[ V{ goodbye } ] [ baz protocol-users ] unit-test

! [ "USING: delegate ;\nIN: delegate.tests\nPROTOCOL: baz foo bar { whoa 1 } ;\n" ]
! [ [ baz see ] with-string-writer ] unit-test

! [ ] [ [ baz forget ] with-compilation-unit ] unit-test
! [ f ] [ goodbye baz method ] unit-test
