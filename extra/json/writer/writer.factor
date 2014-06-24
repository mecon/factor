! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.streams.string io strings splitting sequences math
       math.parser assocs classes words namespaces prettyprint
       hashtables mirrors ;
IN: json.writer

#! Writes the object out to a stream in JSON format
GENERIC: json-print ( obj -- )

: >json ( obj -- string )
  #! Returns a string representing the factor object in JSON format
  [ json-print ] with-string-writer ;

M: f json-print ( f -- )
  drop "false" write ;

M: string json-print ( obj -- )
  CHAR: " write1 "\"" split "\\\"" join CHAR: \r swap remove "\n" split "\\r\\n" join write CHAR: " write1 ;

M: number json-print ( num -- )
  number>string write ;

! sequence and number overlap, we provide an explicit
! disambiguation method
M: integer json-print ( num -- )
  number>string write ;

M: sequence json-print ( array -- )
  CHAR: [ write1 [ >json ] map "," join write CHAR: ] write1 ;

: jsvar-encode ( string -- string )
  #! Convert the string so that it contains characters usable within
  #! javascript variable names.
  { { CHAR: - CHAR: _ } } substitute ;

: tuple>fields ( object -- seq )
  <mirror> [
    [ swap jsvar-encode >json % " : " % >json % ] "" make
  ] { } assoc>map ;

M: tuple json-print ( tuple -- )
  CHAR: { write1 tuple>fields "," join write CHAR: } write1 ;

M: hashtable json-print ( hashtable -- )
  CHAR: { write1
  [ [ swap jsvar-encode >json % CHAR: : , >json % ] "" make ]
  { } assoc>map "," join write
  CHAR: } write1 ;

M: object json-print ( object -- )
    unparse json-print ;
