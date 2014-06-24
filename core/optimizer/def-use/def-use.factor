! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer.def-use
USING: namespaces assocs sequences inference.dataflow
inference.backend kernel generic assocs classes vectors ;

SYMBOL: def-use

: used-by ( value -- seq ) def-use get at ;

: unused? ( value -- ? )
    used-by empty? ;

: uses-values ( node seq -- )
    [ def-use get [ ?push ] change-at ] with each ;

: defs-values ( seq -- )
    #! If there is no value, set it to a new empty vector,
    #! otherwise do nothing.
    [ def-use get [ V{ } like ] change-at ] each ;

GENERIC: node-def-use ( node -- )

: compute-def-use ( node -- )
    H{ } clone def-use set [ node-def-use ] each-node ;

: nest-def-use ( node -- def-use )
    [ compute-def-use def-use get ] with-scope ;

: (node-def-use) ( node -- )
    dup dup node-in-d uses-values
    dup dup node-in-r uses-values
    dup node-out-d defs-values
    node-out-r defs-values ;

M: object node-def-use (node-def-use) ;

! nodes that don't use their values directly
UNION: #passthru
    #shuffle #>r #r> #call-label #merge #values #entry #declare ;

M: #passthru node-def-use drop ;

M: #return node-def-use
    #! Values returned by local labels can be killed.
    dup node-param [ drop ] [ (node-def-use) ] if ;

! nodes that don't use their values directly
UNION: #killable
    #push #passthru ;

: purge-invariants ( stacks -- seq )
    #! Output a sequence of values which are not present in the
    #! same position in each sequence of the stacks sequence.
    unify-lengths flip [ all-eq? not ] subset concat ;

M: #label node-def-use
    [
        dup node-in-d ,
        dup node-child node-out-d ,
        dup collect-recursion [ node-in-d , ] each
    ] { } make purge-invariants uses-values ;

: branch-def-use ( #branch -- )
    active-children [ node-in-d ] map
    purge-invariants t swap uses-values ;

M: #branch node-def-use
    #! This assumes that the last element of each branch is a
    #! #values node.
    dup branch-def-use (node-def-use) ;

: compute-dead-literals ( -- values )
    def-use get [ >r value? r> empty? and ] assoc-subset ;

DEFER: kill-nodes
SYMBOL: dead-literals

GENERIC: kill-node* ( node -- node/t )

M: node kill-node* drop t ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] if ;
    inline

M: #shuffle kill-node*
    [
        dup node-in-d empty? swap node-out-d empty? and
    ] prune-if ;

M: #push kill-node*
    [ node-out-d empty? ] prune-if ;

M: #>r kill-node* [ node-in-d empty? ] prune-if ;

M: #r> kill-node* [ node-in-r empty? ] prune-if ;

: kill-node ( node -- node )
    dup [
        dup [ dead-literals get swap remove-all ] modify-values
        dup kill-node* dup t eq? [
            drop dup [ kill-nodes ] map-children
        ] [
            nip kill-node
        ] if
    ] when ;

: kill-nodes ( node -- newnode )
    [ kill-node ] transform-nodes ;

: kill-values ( node -- new-node )
    #! Remove literals which are not actually used anywhere.
    compute-dead-literals dup assoc-empty? [ drop ] [
        dead-literals [ kill-nodes ] with-variable
    ] if ;

: sole-consumer ( #call -- node/f )
    node-out-d first used-by
    dup length 1 = [ first ] [ drop f ] if ;

: splice-def-use ( node -- )
    #! As a first approximation, we take all the values used
    #! by the set of new nodes, and push a 't' on their
    #! def-use list here. We could perform a full graph
    #! substitution, but we don't need to, because the next
    #! optimizer iteration will do that. We just need a minimal
    #! degree of accuracy; the new values should be marked as
    #! having _some_ usage, so that flushing doesn't erronously
    #! flush them away.
    [ compute-def-use def-use get keys ] with-scope
    def-use get [ [ t swap ?push ] change-at ] curry each ;
