! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inference.backend inference.state inference.dataflow
inference.known-words inference.transforms inference.errors
kernel io effects namespaces sequences quotations vocabs
generic words ;
IN: inference

GENERIC: infer ( quot -- effect )

M: callable infer ( quot -- effect )
    [ f infer-quot ] with-infer drop ;

: infer. ( quot -- )
    infer effect>string print ;

GENERIC: dataflow ( quot -- dataflow )

M: callable dataflow
    [ f infer-quot ] with-infer nip ;

GENERIC# dataflow-with 1 ( quot stack -- dataflow )

M: callable dataflow-with
    [
        V{ } like meta-d set
        f infer-quot
    ] with-infer nip ;

: forget-errors ( -- )
    all-words [
        dup subwords [ f "no-effect" set-word-prop ] each
        f "no-effect" set-word-prop
    ] each ;
