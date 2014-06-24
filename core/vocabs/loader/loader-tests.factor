! Unit tests for vocabs.loader vocabulary
IN: vocabs.loader.tests
USING: vocabs.loader tools.test continuations vocabs math
kernel arrays sequences namespaces io.streams.string
parser source-files words assocs classes.tuple definitions
debugger compiler.units tools.vocabs accessors ;

! This vocab should not exist, but just in case...
[ ] [
    [
        "vocabs.loader.test" forget-vocab
    ] with-compilation-unit
] unit-test

[ T{ vocab-link f "vocabs.loader.test" } ]
[ "vocabs.loader.test" >vocab-link ] unit-test

[ t ]
[ "kernel" >vocab-link "kernel" vocab = ] unit-test

[ t ] [
    "kernel" vocab-files
    "kernel" vocab vocab-files
    "kernel" <vocab-link> vocab-files
    3array all-equal?
] unit-test

IN: vocabs.loader.test.2

: hello 3 ;

MAIN: hello

IN: vocabs.loader.tests

[ { 3 3 3 } ] [
    "vocabs.loader.test.2" run
    "vocabs.loader.test.2" vocab run
    "vocabs.loader.test.2" <vocab-link> run
    3array
] unit-test


[
    "resource:core/vocabs/loader/test/a/a.factor" forget-source
    "vocabs.loader.test.a" forget-vocab
] with-compilation-unit

0 "count-me" set-global

2 [
    [ "vocabs.loader.test.a" require ] must-fail

    [ f ] [ "vocabs.loader.test.a" vocab-source-loaded? ] unit-test

    [ t ] [
        "resource:core/vocabs/loader/test/a/a.factor"
        source-file source-file-definitions dup USE: prettyprint .
        "v-l-t-a-hello" "vocabs.loader.test.a" lookup dup .
        swap first key?
    ] unit-test
] times

[ 2 ] [ "count-me" get-global ] unit-test

[
    "IN: vocabs.loader.test.a v-l-t-a-hello"
    <string-reader>
    "resource:core/vocabs/loader/test/a/a.factor"
    parse-stream
] [ error>> error>> no-word-error? ] must-fail-with

0 "count-me" set-global

[ ] [
    [
        "vocabs.loader.test.b" forget-vocab
    ] with-compilation-unit
] unit-test

[ f ] [ "vocabs.loader.test.b" vocab-files empty? ] unit-test

[ ] [
    [
        "vocabs.loader.test.b" vocab-files
        [ forget-source ] each
    ] with-compilation-unit
] unit-test

[ "vocabs.loader.test.b" require ] must-fail

[ 1 ] [ "count-me" get-global ] unit-test

[ ] [
    [
        "bob" "vocabs.loader.test.b" create [ ] define
    ] with-compilation-unit
] unit-test

[ ] [ "vocabs.loader.test.b" refresh ] unit-test

[ 2 ] [ "count-me" get-global ] unit-test

[ f ] [ "fred" "vocabs.loader.test.b" lookup undefined? ] unit-test

[ ] [
    [
        "vocabs.loader.test.b" vocab-files
        [ forget-source ] each
    ] with-compilation-unit
] unit-test

[ ] [ "vocabs.loader.test.b" changed-vocab ] unit-test

[ ] [ "vocabs.loader.test.b" refresh ] unit-test

[ 3 ] [ "count-me" get-global ] unit-test

[ { "resource:core/kernel/kernel.factor" 1 } ]
[ "kernel" <vocab-link> where ] unit-test

[ { "resource:core/kernel/kernel.factor" 1 } ]
[ "kernel" vocab where ] unit-test

[ ] [
    [
        "vocabs.loader.test.c" forget-vocab
        "vocabs.loader.test.d" forget-vocab
    ] with-compilation-unit
] unit-test

[ t ] [
    [ "vocabs.loader.test.d" require ] [ :1 ] recover
    "vocabs.loader.test.d" vocab-source-loaded?
] unit-test

: forget-junk
    [
        { "2" "a" "b" "d" "e" "f" }
        [
            "vocabs.loader.test." prepend forget-vocab
        ] each
    ] with-compilation-unit ;

forget-junk

[ { } ] [
    "IN: xabbabbja" eval "xabbabbja" vocab-files
] unit-test

[ "xabbabbja" forget-vocab ] with-compilation-unit

forget-junk
