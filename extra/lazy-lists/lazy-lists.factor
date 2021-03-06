! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Updated by Matthew Willis, July 2006
! Updated by Chris Double, September 2006
!
USING: kernel sequences math vectors arrays namespaces
quotations promises combinators io ;
IN: lazy-lists

! Lazy List Protocol
MIXIN: list
GENERIC: car   ( cons -- car )
GENERIC: cdr   ( cons -- cdr )
GENERIC: nil?  ( cons -- ? )

M: promise car ( promise -- car )
  force car ;

M: promise cdr ( promise -- cdr )
  force cdr ;

M: promise nil? ( cons -- bool )
  force nil? ;

TUPLE: cons car cdr ;

C: cons cons

M: cons car ( cons -- car )
    cons-car ;

M: cons cdr ( cons -- cdr )
    cons-cdr ;

: nil ( -- cons )
  T{ cons f f f } ;

M: cons nil? ( cons -- bool )
    nil eq? ;

: 1list ( obj -- cons )
    nil cons ;

: 2list ( a b -- cons )
    nil cons cons ;

: 3list ( a b c -- cons )
    nil cons cons cons ;

! Both 'car' and 'cdr' are promises
TUPLE: lazy-cons car cdr ;

: lazy-cons ( car cdr -- promise )
    [ promise ] bi@ \ lazy-cons construct-boa
    T{ promise f f t f } clone
    [ set-promise-value ] keep ;

M: lazy-cons car ( lazy-cons -- car )
    lazy-cons-car force ;

M: lazy-cons cdr ( lazy-cons -- cdr )
    lazy-cons-cdr force ;

M: lazy-cons nil? ( lazy-cons -- bool )
    nil eq? ;

: 1lazy-list ( a -- lazy-cons )
  [ nil ] lazy-cons ;

: 2lazy-list ( a b -- lazy-cons )
  1lazy-list 1quotation lazy-cons ;

: 3lazy-list ( a b c -- lazy-cons )
  2lazy-list 1quotation lazy-cons ;

: lnth ( n list -- elt )
  swap [ cdr ] times car ;

: (llength) ( list acc -- n )
  over nil? [ nip ] [ [ cdr ] dip 1+ (llength) ] if ;

: llength ( list -- n )
  0 (llength) ;

: uncons ( cons -- car cdr )
    #! Return the car and cdr of the lazy list
    dup car swap cdr ;

: leach ( list quot -- )
  swap dup nil? [ 2drop ] [ uncons swapd over 2slip leach ] if ; inline

: lreduce ( list identity quot -- result )
  swapd leach ; inline

TUPLE: memoized-cons original car cdr nil? ;

: not-memoized ( -- obj )
  { } ;

: not-memoized? ( obj -- bool )
  not-memoized eq? ;

: <memoized-cons> ( cons -- memoized-cons )
  not-memoized not-memoized not-memoized
  memoized-cons construct-boa ;

M: memoized-cons car ( memoized-cons -- car )
  dup memoized-cons-car not-memoized? [
    dup memoized-cons-original car [ swap set-memoized-cons-car ] keep
  ] [
    memoized-cons-car
  ] if ;

M: memoized-cons cdr ( memoized-cons -- cdr )
  dup memoized-cons-cdr not-memoized? [
    dup memoized-cons-original cdr [ swap set-memoized-cons-cdr ] keep
  ] [
    memoized-cons-cdr
  ] if ;

M: memoized-cons nil? ( memoized-cons -- bool )
  dup memoized-cons-nil? not-memoized? [
    dup memoized-cons-original nil? [ swap set-memoized-cons-nil? ] keep
  ] [
    memoized-cons-nil?
  ] if ;

TUPLE: lazy-map cons quot ;

C: <lazy-map> lazy-map

: lmap ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-map> <memoized-cons> ] if ;

M: lazy-map car ( lazy-map -- car )
  [ lazy-map-cons car ] keep
  lazy-map-quot call ;

M: lazy-map cdr ( lazy-map -- cdr )
  [ lazy-map-cons cdr ] keep
  lazy-map-quot lmap ;

M: lazy-map nil? ( lazy-map -- bool )
  lazy-map-cons nil? ;

: lmap-with ( value list quot -- result )
  with lmap ;

TUPLE: lazy-take n cons ;

C: <lazy-take> lazy-take

: ltake ( n list -- result )
    over zero? [ 2drop nil ] [ <lazy-take> ] if ;

M: lazy-take car ( lazy-take -- car )
  lazy-take-cons car ;

M: lazy-take cdr ( lazy-take -- cdr )
  [ lazy-take-n 1- ] keep
  lazy-take-cons cdr ltake ;

M: lazy-take nil? ( lazy-take -- bool )
  dup lazy-take-n zero? [
    drop t
  ] [
    lazy-take-cons nil?
  ] if ;

TUPLE: lazy-until cons quot ;

C: <lazy-until> lazy-until

: luntil ( list quot -- result )
  over nil? [ drop ] [ <lazy-until> ] if ;

M: lazy-until car ( lazy-until -- car )
   lazy-until-cons car ;

M: lazy-until cdr ( lazy-until -- cdr )
   [ lazy-until-cons uncons swap ] keep lazy-until-quot tuck call
   [ 2drop nil ] [ luntil ] if ;

M: lazy-until nil? ( lazy-until -- bool )
   drop f ;

TUPLE: lazy-while cons quot ;

C: <lazy-while> lazy-while

: lwhile ( list quot -- result )
  over nil? [ drop ] [ <lazy-while> ] if ;

M: lazy-while car ( lazy-while -- car )
   lazy-while-cons car ;

M: lazy-while cdr ( lazy-while -- cdr )
   [ lazy-while-cons cdr ] keep lazy-while-quot lwhile ;

M: lazy-while nil? ( lazy-while -- bool )
   [ car ] keep lazy-while-quot call not ;

TUPLE: lazy-subset cons quot ;

C: <lazy-subset> lazy-subset

: lsubset ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-subset> <memoized-cons> ] if ;

: car-subset?  ( lazy-subset -- ? )
  [ lazy-subset-cons car ] keep
  lazy-subset-quot call ;

: skip ( lazy-subset -- )
  [ lazy-subset-cons cdr ] keep
  set-lazy-subset-cons ;

M: lazy-subset car ( lazy-subset -- car )
  dup car-subset? [ lazy-subset-cons ] [ dup skip ] if car ;

M: lazy-subset cdr ( lazy-subset -- cdr )
  dup car-subset? [
    [ lazy-subset-cons cdr ] keep
    lazy-subset-quot lsubset
  ] [
    dup skip cdr
  ] if ;

M: lazy-subset nil? ( lazy-subset -- bool )
  dup lazy-subset-cons nil? [
    drop t
  ] [
    dup car-subset? [
      drop f
    ] [
      dup skip nil?
    ] if
  ] if ;

: list>vector ( list -- vector )
  [ [ , ] leach ] V{ } make ;

: list>array ( list -- array )
  [ [ , ] leach ] { } make ;

TUPLE: lazy-append list1 list2 ;

C: <lazy-append> lazy-append

: lappend ( list1 list2 -- result )
  over nil? [ nip ] [ <lazy-append> ] if ;

M: lazy-append car ( lazy-append -- car )
  lazy-append-list1 car ;

M: lazy-append cdr ( lazy-append -- cdr )
  [ lazy-append-list1 cdr  ] keep
  lazy-append-list2 lappend ;

M: lazy-append nil? ( lazy-append -- bool )
   drop f ;

TUPLE: lazy-from-by n quot ;

C: lfrom-by lazy-from-by ( n quot -- list )

: lfrom ( n -- list )
  [ 1+ ] lfrom-by ;

M: lazy-from-by car ( lazy-from-by -- car )
  lazy-from-by-n ;

M: lazy-from-by cdr ( lazy-from-by -- cdr )
  [ lazy-from-by-n ] keep
  lazy-from-by-quot dup slip lfrom-by ;

M: lazy-from-by nil? ( lazy-from-by -- bool )
  drop f ;

TUPLE: lazy-zip list1 list2 ;

C: <lazy-zip> lazy-zip

: lzip ( list1 list2 -- lazy-zip )
    over nil? over nil? or
    [ 2drop nil ] [ <lazy-zip> ] if ;

M: lazy-zip car ( lazy-zip -- car )
    [ lazy-zip-list1 car ] keep lazy-zip-list2 car 2array ;

M: lazy-zip cdr ( lazy-zip -- cdr )
    [ lazy-zip-list1 cdr ] keep lazy-zip-list2 cdr lzip ;

M: lazy-zip nil? ( lazy-zip -- bool )
    drop f ;

TUPLE: sequence-cons index seq ;

C: <sequence-cons> sequence-cons

: seq>list ( index seq -- list )
  2dup length >= [
    2drop nil
  ] [
    <sequence-cons>
  ] if ;

M: sequence-cons car ( sequence-cons -- car )
  [ sequence-cons-index ] keep
  sequence-cons-seq nth ;

M: sequence-cons cdr ( sequence-cons -- cdr )
  [ sequence-cons-index 1+ ] keep
  sequence-cons-seq seq>list ;

M: sequence-cons nil? ( sequence-cons -- bool )
    drop f ;

: >list ( object -- list )
  {
    { [ dup sequence? ] [ 0 swap seq>list ] }
    { [ dup list?     ] [ ] }
    [ "Could not convert object to a list" throw ]
  } cond ;

TUPLE: lazy-concat car cdr ;

C: <lazy-concat> lazy-concat

DEFER: lconcat

: (lconcat) ( car cdr -- list )
  over nil? [
    nip lconcat
  ] [
    <lazy-concat>
  ] if ;

: lconcat ( list -- result )
  dup nil? [
    drop nil
  ] [
    uncons (lconcat)
  ] if ;

M: lazy-concat car ( lazy-concat -- car )
  lazy-concat-car car ;

M: lazy-concat cdr ( lazy-concat -- cdr )
  [ lazy-concat-car cdr ] keep lazy-concat-cdr (lconcat) ;

M: lazy-concat nil? ( lazy-concat -- bool )
  dup lazy-concat-car nil? [
    lazy-concat-cdr nil?
  ] [
    drop f
  ] if ;

: lcartesian-product ( list1 list2 -- result )
  swap [ swap [ 2array ] lmap-with ] lmap-with lconcat ;

: lcartesian-product* ( lists -- result )
  dup nil? [
    drop nil
  ] [
    [ car ] keep cdr [ car lcartesian-product ] keep cdr list>array swap [
      swap [ swap [ suffix ] lmap-with ] lmap-with lconcat
    ] reduce
  ] if ;

: lcomp ( list quot -- result )
  [ lcartesian-product* ] dip lmap ;

: lcomp* ( list guards quot -- result )
  [ [ lcartesian-product* ] dip [ lsubset ] each ] dip lmap ;

DEFER: lmerge

: (lmerge) ( list1 list2 -- result )
  over [ car ] curry -rot
  [
    dup [ car ] curry -rot
    [
      [ cdr ] bi@ lmerge
    ] 2curry lazy-cons
  ] 2curry lazy-cons ;

: lmerge ( list1 list2 -- result )
  {
    { [ over nil? ] [ nip   ] }
    { [ dup nil?  ]  [ drop ] }
    { [ t         ]  [ (lmerge) ] }
  } cond ;

TUPLE: lazy-io stream car cdr quot ;

C: <lazy-io> lazy-io

: lcontents ( stream -- result )
  f f [ stream-read1 ] <lazy-io> ;

: llines ( stream -- result )
  f f [ stream-readln ] <lazy-io> ;

M: lazy-io car ( lazy-io -- car )
  dup lazy-io-car dup [
    nip
  ] [
    drop dup lazy-io-stream over lazy-io-quot call
    swap dupd set-lazy-io-car
  ] if ;

M: lazy-io cdr ( lazy-io -- cdr )
  dup lazy-io-cdr dup [
    nip
  ] [
    drop dup
    [ lazy-io-stream ] keep
    [ lazy-io-quot ] keep
    car [
      [ f f ] dip <lazy-io> [ swap set-lazy-io-cdr ] keep
    ] [
      3drop nil
    ] if
  ] if ;

M: lazy-io nil? ( lazy-io -- bool )
  car not ;

INSTANCE: cons list
INSTANCE: sequence-cons list
INSTANCE: memoized-cons list
INSTANCE: promise list
INSTANCE: lazy-io list
INSTANCE: lazy-concat list
INSTANCE: lazy-cons list
INSTANCE: lazy-map list
INSTANCE: lazy-take list
INSTANCE: lazy-append list
INSTANCE: lazy-from-by list
INSTANCE: lazy-zip list
INSTANCE: lazy-while list
INSTANCE: lazy-until list
INSTANCE: lazy-subset list
