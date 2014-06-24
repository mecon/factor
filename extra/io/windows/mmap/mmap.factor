USING: alien alien.c-types alien.syntax arrays continuations
destructors generic io.mmap io.nonblocking io.windows
kernel libc math namespaces quotations sequences windows
windows.advapi32 windows.kernel32 io.backend system ;
IN: io.windows.mmap

TYPEDEF: TOKEN_PRIVILEGES* PTOKEN_PRIVILEGES

! Security tokens
!  http://msdn.microsoft.com/msdnmag/issues/05/03/TokenPrivileges/

: (open-process-token) ( handle -- handle )
    TOKEN_ADJUST_PRIVILEGES TOKEN_QUERY bitor "PHANDLE" <c-object>
    [ OpenProcessToken win32-error=0/f ] keep *void* ;

: open-process-token ( -- handle )
    #! remember to handle-close this
    GetCurrentProcess (open-process-token) ;

: with-process-token ( quot -- )
    #! quot: ( token-handle -- token-handle )
    >r open-process-token r>
    [ keep ] curry
    [ CloseHandle drop ] [ ] cleanup ; inline

: lookup-privilege ( string -- luid )
    >r f r> "LUID" <c-object>
    [ LookupPrivilegeValue win32-error=0/f ] keep ;

: make-token-privileges ( name ? -- obj )
    "TOKEN_PRIVILEGES" <c-object>
    1 [ over set-TOKEN_PRIVILEGES-PrivilegeCount ] keep
    "LUID_AND_ATTRIBUTES" malloc-array
    dup free-always over set-TOKEN_PRIVILEGES-Privileges

    swap [
        SE_PRIVILEGE_ENABLED over TOKEN_PRIVILEGES-Privileges
        set-LUID_AND_ATTRIBUTES-Attributes
    ] when

    >r lookup-privilege r>
    [
        TOKEN_PRIVILEGES-Privileges
        >r 0 r> LUID_AND_ATTRIBUTES-nth
        set-LUID_AND_ATTRIBUTES-Luid
    ] keep ;

: set-privilege ( name ? -- )
    [
        -rot 0 -rot make-token-privileges
        dup length f f AdjustTokenPrivileges win32-error=0/f
    ] with-process-token ;

HOOK: with-privileges io-backend ( seq quot -- ) inline

M: winnt with-privileges
    over [ [ t set-privilege ] each ] curry compose
    swap [ [ f set-privilege ] each ] curry [ ] cleanup ;

M: wince with-privileges
    nip call ;

: mmap-open ( path access-mode create-mode flProtect access -- handle handle address )
    { "SeCreateGlobalPrivilege" "SeLockMemoryPrivilege" } [
        >r >r 0 open-file dup f r> 0 0 f
        CreateFileMapping [ win32-error=0/f ] keep
        dup close-later
        dup
        r> 0 0 0 MapViewOfFile [ win32-error=0/f ] keep
        dup close-later
    ] with-privileges ;

M: windows <mapped-file> ( path length -- mmap )
    [
        swap
        GENERIC_WRITE GENERIC_READ bitor
        OPEN_ALWAYS
        PAGE_READWRITE SEC_COMMIT bitor
        FILE_MAP_ALL_ACCESS mmap-open
        -rot 2array
        f \ mapped-file construct-boa
    ] with-destructors ;

M: windows close-mapped-file ( mapped-file -- )
    [
        dup mapped-file-handle [ close-always ] each
        mapped-file-address UnmapViewOfFile win32-error=0/f
    ] with-destructors ;
