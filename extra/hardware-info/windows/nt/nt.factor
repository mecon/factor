USING: alien alien.c-types
kernel libc math namespaces hardware-info.backend
windows windows.advapi32 windows.kernel32 system ;
IN: hardware-info.windows.nt

: system-info ( -- SYSTEM_INFO )
    "SYSTEM_INFO" <c-object> [ GetSystemInfo ] keep ;

M: winnt cpus ( -- n )
    system-info SYSTEM_INFO-dwNumberOfProcessors ;

: memory-status ( -- MEMORYSTATUSEX )
    "MEMORYSTATUSEX" <c-object>
    "MEMORYSTATUSEX" heap-size over set-MEMORYSTATUSEX-dwLength
    [ GlobalMemoryStatusEx ] keep swap zero? [ win32-error ] when ;

M: winnt memory-load ( -- n )
    memory-status MEMORYSTATUSEX-dwMemoryLoad ;

M: winnt physical-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalPhys ;

M: winnt available-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailPhys ;

M: winnt total-page-file ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalPageFile ;

M: winnt available-page-file ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailPageFile ;

M: winnt total-virtual-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalVirtual ;

M: winnt available-virtual-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailVirtual ;

: computer-name ( -- string )
    MAX_COMPUTERNAME_LENGTH 1+ [ malloc ] keep
    <int> dupd GetComputerName zero? [
        free win32-error f
    ] [
        [ alien>u16-string ] keep free
    ] if ;
 
: username ( -- string )
    UNLEN 1+ [ malloc ] keep
    <int> dupd GetUserName zero? [
        free win32-error f
    ] [
        [ alien>u16-string ] keep free
    ] if ;
