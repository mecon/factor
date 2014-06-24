
USING: kernel words namespaces classes parser continuations
       io io.files io.launcher io.sockets
       math math.parser
       system
       combinators sequences splitting quotations arrays strings tools.time
       sequences.deep accessors assocs.lib
       io.encodings.utf8
       combinators.cleave bake calendar calendar.format ;

IN: builder.util

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

: minutes>ms ( min -- ms ) 60 * 1000 * ;

: file>string ( file -- string ) utf8 [ stdio get contents ] with-file-reader ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: to-strings

: to-string ( obj -- str )
  dup class
    {
      { string    [ ] }
      { quotation [ call ] }
      { word      [ execute ] }
      { fixnum    [ number>string ] }
      { array     [ to-strings concat ] }
    }
  case ;

: to-strings ( seq -- str )
  dup [ string? ] all?
    [ ]
    [ [ to-string ] map flatten ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: host-name* ( -- name ) host-name "." split first ;

: datestamp ( -- string )
  now `{ ,[ dup timestamp-year   ]
         ,[ dup timestamp-month  ]
         ,[ dup timestamp-day    ]
         ,[ dup timestamp-hour   ]
         ,[     timestamp-minute ] }
  [ pad-00 ] map "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: milli-seconds>time ( n -- string )
  1000 /i 60 /mod >r 60 /mod r> 3array [ pad-00 ] map ":" join ;

: eval-file ( file -- obj ) utf8 file-contents eval ;

: cat ( file -- ) utf8 file-contents print ;

: run-or-bail ( desc quot -- )
  [ [ try-process ] curry   ]
  [ [ throw       ] compose ]
  bi*
  recover ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: bootstrap.image bootstrap.image.download io.streams.null ;

: retrieve-image ( -- ) [ my-arch download-image ] with-null-stream ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longer? ( seq seq -- ? ) [ length ] bi@ > ;

: maybe-tail* ( seq n -- seq )
  2dup longer?
    [ tail* ]
    [ drop  ]
  if ;

: cat-n ( file n -- )
  [ utf8 file-lines ] [ ] bi*
  maybe-tail*
  [ print ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: prettyprint

: to-file ( object file -- ) utf8 [ . ] with-file-writer ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cpu- ( -- cpu ) cpu unparse "." split "-" join ;

: platform ( -- string ) { [ os unparse ] cpu- } to-strings "-" join ;