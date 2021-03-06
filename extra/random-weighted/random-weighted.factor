
USING: kernel namespaces arrays quotations sequences assocs combinators
       mirrors math math.vectors random macros bake ;

IN: random-weighted

: probabilities ( weights -- probabilities ) dup sum v/n ;

: layers ( probabilities -- layers )
dup length 1+ [ head ] with map 1 tail [ sum ] map ;

: random-weighted ( weights -- elt )
probabilities layers [ 1000 * ] map 1000 random [ > ] curry find drop ;

: random-weighted* ( seq -- elt )
dup [ second ] map swap [ first ] map random-weighted swap nth ;

MACRO: call-random-weighted ( exp -- )
  [ keys ] [ values <enum> >alist ] bi swap
  [ , random-weighted , case ] bake ;
