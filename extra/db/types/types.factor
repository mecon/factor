! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs db kernel math math.parser
sequences continuations sequences.deep sequences.lib
words namespaces tools.walker slots slots.private classes
mirrors classes.tuple combinators calendar.format symbols
classes.singleton ;
IN: db.types

HOOK: modifier-table db ( -- hash )
HOOK: compound-modifier db ( str seq -- hash )
HOOK: type-table db ( -- hash )
HOOK: create-type-table db ( -- hash )
HOOK: compound-type db ( str n -- hash )

TUPLE: sql-spec class slot-name column-name type modifiers primary-key ;

SINGLETON: +native-id+
SINGLETON: +assigned-id+
SINGLETON: +random-id+
UNION: +primary-key+ +native-id+ +assigned-id+ +random-id+ ;
UNION: +nonnative-id+ +random-id+ +assigned-id+ ;

SYMBOLS: +autoincrement+ +serial+ +unique+ +default+ +null+ +not-null+
+foreign-id+ +has-many+ ;

: primary-key? ( spec -- ? )
    sql-spec-primary-key +primary-key+? ;

: native-id? ( spec -- ? )
    sql-spec-primary-key +native-id+? ;

: nonnative-id? ( spec -- ? )
    sql-spec-primary-key +nonnative-id+? ;

: normalize-spec ( spec -- )
    dup sql-spec-type dup +primary-key+? [
        swap set-sql-spec-primary-key
    ] [
        drop dup sql-spec-modifiers [
            +primary-key+?
        ] deep-find
        [ swap set-sql-spec-primary-key ] [ drop ] if*
    ] if ;

: find-primary-key ( specs -- obj )
    [ sql-spec-primary-key ] find nip ;

: relation? ( spec -- ? ) [ +has-many+ = ] deep-find ;

SYMBOLS: INTEGER BIG-INTEGER DOUBLE REAL BOOLEAN TEXT VARCHAR
DATE TIME DATETIME TIMESTAMP BLOB FACTOR-BLOB NULL ;

: spec>tuple ( class spec -- tuple )
    [ ?first3 ] keep 3 ?tail*
    {
        set-sql-spec-class
        set-sql-spec-slot-name
        set-sql-spec-column-name
        set-sql-spec-type
        set-sql-spec-modifiers
    } sql-spec construct
    dup normalize-spec ;

TUPLE: no-sql-type ;
: no-sql-type ( -- * ) T{ no-sql-type } throw ;

TUPLE: no-sql-modifier ;
: no-sql-modifier ( -- * ) T{ no-sql-modifier } throw ;

: number>string* ( n/str -- str )
    dup number? [ number>string ] when ;

: maybe-remove-id ( specs -- obj )
    [ +native-id+? not ] subset ;

: remove-relations ( specs -- newcolumns )
    [ relation? not ] subset ;

: remove-id ( specs -- obj )
    [ sql-spec-primary-key not ] subset ;

! SQLite Types: http://www.sqlite.org/datatype3.html
! NULL INTEGER REAL TEXT BLOB
! PostgreSQL Types:
! http://developer.postgresql.org/pgdocs/postgres/datatype.html

: lookup-modifier ( obj -- str )
    dup array? [
        unclip lookup-modifier swap compound-modifier
    ] [
        modifier-table at*
        [ "unknown modifier" throw ] unless
    ] if ;

: lookup-type* ( obj -- str )
    dup array? [
        first lookup-type*
    ] [
        type-table at*
        [ no-sql-type ] unless
    ] if ;

: lookup-create-type ( obj -- str )
    dup array? [
        unclip lookup-create-type swap compound-type
    ] [
        dup create-type-table at*
        [ nip ] [ drop lookup-type* ] if
    ] if ;

: lookup-type ( obj create? -- str )
    [ lookup-create-type ] [ lookup-type* ] if ;

: single-quote ( str -- newstr )
    "'" swap "'" 3append ;

: double-quote ( str -- newstr )
    "\"" swap "\"" 3append ;

: paren ( str -- newstr )
    "(" swap ")" 3append ;

: join-space ( str1 str2 -- newstr )
    " " swap 3append ;

: modifiers ( spec -- str )
    sql-spec-modifiers
    [ lookup-modifier ] map " " join
    dup empty? [ " " prepend ] unless ;

HOOK: bind% db ( spec -- )

: offset-of-slot ( str obj -- n )
    class "slots" word-prop slot-named slot-spec-offset ;

: get-slot-named ( name obj -- value )
    tuck offset-of-slot slot ;

: set-slot-named ( value name obj -- )
    tuck offset-of-slot set-slot ;

: tuple>filled-slots ( tuple -- alist )
    <mirror> [ nip ] assoc-subset ;

: tuple>params ( specs tuple -- obj )
    [
        >r dup sql-spec-type swap sql-spec-slot-name r>
        get-slot-named swap
    ] curry { } map>assoc ;
