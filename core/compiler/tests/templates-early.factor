! Testing templates machinery without compiling anything
IN: compiler.tests
USING: compiler generator generator.registers
generator.registers.private tools.test namespaces sequences
words kernel math effects definitions compiler.units accessors ;

: <int-vreg> ( n -- vreg ) int-regs <vreg> ;

[
    [ ] [ init-templates ] unit-test

    [ V{ 3 } ] [ 3 fresh-object fresh-objects get ] unit-test

    [ ] [ 0 <int-vreg> phantom-push ] unit-test

    [ ] [ compute-free-vregs ] unit-test

    [ f ] [ 0 <int-vreg> int-regs free-vregs member? ] unit-test

    [ f ] [
        [
            copy-templates
            1 <int-vreg> phantom-push
            compute-free-vregs
            1 <int-vreg> int-regs free-vregs member?
        ] with-scope
    ] unit-test

    [ t ] [ 1 <int-vreg> int-regs free-vregs member? ] unit-test
] with-scope

[
    [ ] [ init-templates ] unit-test

    [ ] [ T{ effect f 3 { 1 2 0 } f } phantom-shuffle ] unit-test

    [ 3 ] [ live-locs length ] unit-test

    [ ] [ T{ effect f 2 { 1 0 } f } phantom-shuffle ] unit-test

    [ 2 ] [ live-locs length ] unit-test
] with-scope

[
    [ ] [ init-templates ] unit-test

    H{ } clone compiled set

    [ ] [ gensym gensym begin-compiling ] unit-test

    [ t ] [ [ end-basic-block ] { } make empty? ] unit-test

    3 fresh-object

    [ f ] [ [ end-basic-block ] { } make empty? ] unit-test
] with-scope

[
    [ ] [ init-templates ] unit-test

    H{
        { +input+ { { f "x" } } }
    } clone [
        [ 1 0 ] [ +input+ get { } { } guess-vregs ] unit-test
        [ ] [ finalize-contents ] unit-test
        [ ] [ [ template-inputs ] { } make drop ] unit-test
    ] bind
] with-scope

! Test template picking strategy
SYMBOL: template-chosen

: template-test ( a b -- c d ) ;

\ template-test {
    {
        [
            1 template-chosen get push
        ] H{
            { +input+ { { f "obj" } { [ ] "n" } } }
            { +output+ { "obj" "obj" } }
        }
    }
    {
        [
            2 template-chosen get push
        ] H{
            { +input+ { { f "obj" } { f "n" } } }
            { +output+ { "obj" "n" } }
        }
    }
} define-intrinsics

[ V{ 2 } ] [
    V{ } clone template-chosen set
    0 0 [ template-test ] compile-call 2drop
    template-chosen get
] unit-test

[ V{ 1 } ] [
    V{ } clone template-chosen set
    1 [ dup 0 template-test ] compile-call 3drop
    template-chosen get
] unit-test

[ V{ 1 } ] [
    V{ } clone template-chosen set
    1 [ 0 template-test ] compile-call 2drop
    template-chosen get
] unit-test

! Regression
[
    [ ] [ init-templates ] unit-test

    ! dup dup
    [ ] [
        T{ effect f { "x" } { "x" "x" } } phantom-shuffle
        T{ effect f { "x" } { "x" "x" } } phantom-shuffle
    ] unit-test

    ! This is not empty since a load instruction is emitted
    [ f ] [
        [ { { f "x" } } +input+ set load-inputs ] { } make
        empty?
    ] unit-test

    ! This is empty since we already loaded the value
    [ t ] [
        [ { { f "x" } } +input+ set load-inputs ] { } make
        empty?
    ] unit-test

    ! This is empty since we didn't change the stack
    [ t ] [ [ end-basic-block ] { } make empty? ] unit-test
] with-scope

! Regression
[
    [ ] [ init-templates ] unit-test

    ! >r r>
    [ ] [
        1 phantom->r
        1 phantom-r>
    ] unit-test

    ! This is empty since we didn't change the stack
    [ t ] [ [ end-basic-block ] { } make empty? ] unit-test

    ! >r r>
    [ ] [
        1 phantom->r
        1 phantom-r>
    ] unit-test

    [ ] [ { object } set-operand-classes ] unit-test

    ! This is empty since we didn't change the stack
    [ t ] [ [ end-basic-block ] { } make empty? ] unit-test
] with-scope

! Regression
[
    [ ] [ init-templates ] unit-test

    [ ] [ { object object } set-operand-classes ] unit-test

    ! 2dup
    [ ] [
        T{ effect f { "x" "y" } { "x" "y" "x" "y" } }
        phantom-shuffle
    ] unit-test

    [ ] [
        2 phantom-datastack get phantom-input
        [ { { f "a" } { f "b" } } lazy-load ] { } make drop
    ] unit-test

    [ t ] [
        phantom-datastack get stack>> [ cached? ] all?
    ] unit-test

    ! >r
    [ ] [
        1 phantom->r
    ] unit-test

    ! This should not fail
    [ ] [ [ end-basic-block ] { } make drop ] unit-test
] with-scope

! Regression
SYMBOL: templates-chosen

V{ } clone templates-chosen set

: template-choice-1 ;

\ template-choice-1
[ "template-choice-1" templates-chosen get push ]
H{
    { +input+ { { f "obj" } { [ ] "n" } } }
    { +output+ { "obj" } }
} define-intrinsic

: template-choice-2 ;

\ template-choice-2
[ "template-choice-2" templates-chosen get push drop ]
{ { f "x" } { f "y" } } define-if-intrinsic

[ ] [
    [ 2 template-choice-1 template-choice-2 ]
    [ define-temp ] with-compilation-unit drop
] unit-test

[ V{ "template-choice-1" "template-choice-2" } ]
[ templates-chosen get ] unit-test
