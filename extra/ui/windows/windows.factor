! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays assocs ui ui.gadgets
ui.backend ui.clipboards ui.gadgets.worlds ui.gestures io kernel
math math.vectors namespaces prettyprint sequences strings
vectors words windows.kernel32 windows.gdi32 windows.user32
windows.opengl32 windows.messages windows.types windows.nt
windows threads libc combinators continuations command-line
shuffle opengl ui.render unicode.case ascii math.bitfields
locals symbols accessors ;
IN: ui.windows

SINGLETON: windows-ui-backend

: crlf>lf CHAR: \r swap remove ;
: lf>crlf [ [ dup CHAR: \n = [ CHAR: \r , ] when , ] each ] "" make ;

: enum-clipboard ( -- seq )
    0
    [ EnumClipboardFormats win32-error dup dup 0 > ]
    [ ]
    [ drop ]
    unfold nip ;

: with-clipboard ( quot -- )
    f OpenClipboard win32-error=0/f
    call
    CloseClipboard win32-error=0/f ; inline

: paste ( -- str )
    [
        CF_UNICODETEXT IsClipboardFormatAvailable zero? [
            ! nothing to paste
            ""
        ] [
            CF_UNICODETEXT GetClipboardData dup win32-error=0/f
            dup GlobalLock dup win32-error=0/f
            GlobalUnlock win32-error=0/f
            alien>u16-string
        ] if
    ] with-clipboard
    crlf>lf ;

: copy ( str -- )
    lf>crlf [
        string>u16-alien
        EmptyClipboard win32-error=0/f
        GMEM_MOVEABLE over length 1+ GlobalAlloc
            dup win32-error=0/f

        dup GlobalLock dup win32-error=0/f
        swapd byte-array>memory
        dup GlobalUnlock win32-error=0/f
        CF_UNICODETEXT swap SetClipboardData win32-error=0/f
    ] with-clipboard ;

TUPLE: pasteboard ;
C: <pasteboard> pasteboard

M: pasteboard clipboard-contents drop paste ;
M: pasteboard set-clipboard-contents drop copy ;

: init-clipboard ( -- )
    <pasteboard> clipboard set-global
    <clipboard> selection set-global ;

! world-handle is a <win>
TUPLE: win hWnd hDC hRC world title ;
C: <win> win

SYMBOLS: msg-obj class-name-ptr mouse-captured ;

: style ( -- n ) WS_OVERLAPPEDWINDOW ; inline
: ex-style ( -- n ) WS_EX_APPWINDOW WS_EX_WINDOWEDGE bitor ; inline

: get-RECT-top-left ( RECT -- x y )
    [ RECT-left ] keep RECT-top ;

: get-RECT-dimensions ( RECT -- x y width height )
    [ get-RECT-top-left ] keep
    [ RECT-right ] keep [ RECT-left - ] keep
    [ RECT-bottom ] keep RECT-top - ;

: handle-wm-paint ( hWnd uMsg wParam lParam -- )
    #! wParam and lParam are unused
    #! only paint if width/height both > 0
    3drop window relayout-1 yield ;

: handle-wm-size ( hWnd uMsg wParam lParam -- )
    2nip
    [ lo-word ] keep hi-word 2array
    dup { 0 0 } = [ 2drop ] [ swap window set-gadget-dim ] if ;

: handle-wm-move ( hWnd uMsg wParam lParam -- )
    2nip
    [ lo-word ] keep hi-word 2array
    swap window set-world-loc ;

: wm-keydown-codes ( -- key )
    H{
        { 8 "BACKSPACE" }
        { 9 "TAB" }
        { 13 "RET" }
        { 27 "ESC" }
        { 33 "PAGE_UP" }
        { 34 "PAGE_DOWN" }
        { 35 "END" }
        { 36 "HOME" }
        { 37 "LEFT" }
        { 38 "UP" }
        { 39 "RIGHT" }
        { 40 "DOWN" }
        { 45 "INSERT" }
        { 46 "DELETE" }
        { 112 "F1" }
        { 113 "F2" }
        { 114 "F3" }
        { 115 "F4" }
        { 116 "F5" }
        { 117 "F6" }
        { 118 "F7" }
        { 119 "F8" }
        { 120 "F9" }
        { 121 "F10" }
        { 122 "F11" }
        { 123 "F12" }
    } ;

: key-state-down?
    GetKeyState 16 bit? ;

: left-shift? ( -- ? ) VK_LSHIFT key-state-down? ;
: left-ctrl? ( -- ? ) VK_LCONTROL key-state-down? ;
: left-alt? ( -- ? ) VK_LMENU key-state-down? ;
: right-shift? ( -- ? ) VK_RSHIFT key-state-down? ;
: right-ctrl? ( -- ? ) VK_RCONTROL key-state-down? ;
: right-alt? ( -- ? ) VK_RMENU key-state-down? ;
: shift? ( -- ? ) left-shift? right-shift? or ;
: ctrl? ( -- ? ) left-ctrl? right-ctrl? or ;
: alt? ( -- ? ) left-alt? right-alt? or ;
: caps-lock? ( -- ? ) VK_CAPITAL GetKeyState zero? not ;

: switch-case ( seq -- seq )
    dup first CHAR: a >= [ >upper ] [ >lower ] if ;

: switch-case? ( -- ? ) shift? caps-lock? xor not ;

: key-modifiers ( -- seq )
    [
        shift? [ S+ , ] when
        ctrl? [ C+ , ] when
        alt? [ A+ , ] when
    ] { } make [ empty? not ] keep f ? ;

: exclude-keys-wm-keydown
    H{
        { 16 "SHIFT" }
        { 17 "CTRL" }
        { 18 "ALT" }
        { 20 "CAPS-LOCK" }
    } ;

: exclude-keys-wm-char
    ! Values are ignored
    H{
        { 8 "BACKSPACE" }
        { 9 "TAB" }
        { 13 "RET" }
        { 27 "ESC" }
    } ;

: exclude-key-wm-keydown? ( n -- bool )
    exclude-keys-wm-keydown key? ;

: exclude-key-wm-char? ( n -- bool )
    exclude-keys-wm-char key? ;

: keystroke>gesture ( n -- mods sym ? )
    dup wm-keydown-codes at* [
        nip >r key-modifiers r> t
    ] [
        drop 1string >r key-modifiers r>
        C+ pick member? >r A+ pick member? r> or [
            shift? [ >lower ] unless f
        ] [
            switch-case? [ switch-case ] when t
        ] if
    ] if ;

:: handle-wm-keydown ( hWnd uMsg wParam lParam -- )
    wParam exclude-key-wm-keydown? [
        wParam keystroke>gesture <key-down>
        hWnd window-focus send-gesture drop
    ] unless ;

:: handle-wm-char ( hWnd uMsg wParam lParam -- )
    wParam exclude-key-wm-char? ctrl? alt? xor or [
        wParam 1string
        hWnd window-focus user-input
    ] unless ;

:: handle-wm-keyup ( hWnd uMsg wParam lParam -- )
    wParam keystroke>gesture <key-up>
    hWnd window-focus send-gesture drop ;

: set-window-active ( hwnd uMsg wParam lParam ? -- n )
    >r 4dup r> 2nip nip
    swap window set-world-active? DefWindowProc ;

: handle-wm-syscommand ( hWnd uMsg wParam lParam -- n )
    {
        { [ over SC_MINIMIZE = ] [ f set-window-active ] }
        { [ over SC_RESTORE = ] [ t set-window-active ] }
        { [ over SC_MAXIMIZE = ] [ t set-window-active ] }
        { [ dup alpha? ] [ 4drop 0 ] }
        { [ t ] [ DefWindowProc ] }
    } cond ;

: cleanup-window ( handle -- )
    dup win-title [ free ] when*
    dup win-hRC wglDeleteContext win32-error=0/f
    dup win-hWnd swap win-hDC ReleaseDC win32-error=0/f ;

M: windows-ui-backend (close-window)
    dup win-hWnd unregister-window
    dup cleanup-window
    win-hWnd DestroyWindow win32-error=0/f ;

: handle-wm-close ( hWnd uMsg wParam lParam -- )
    3drop window ungraft ;

: handle-wm-set-focus ( hWnd uMsg wParam lParam -- )
    3drop window [ focus-world ] when* ;

: handle-wm-kill-focus ( hWnd uMsg wParam lParam -- )
    3drop window [ unfocus-world ] when* ;

: message>button ( uMsg -- button down? )
    {
        { [ dup WM_LBUTTONDOWN   = ] [ drop 1 t ] }
        { [ dup WM_LBUTTONUP     = ] [ drop 1 f ] }
        { [ dup WM_MBUTTONDOWN   = ] [ drop 2 t ] }
        { [ dup WM_MBUTTONUP     = ] [ drop 2 f ] }
        { [ dup WM_RBUTTONDOWN   = ] [ drop 3 t ] }
        { [ dup WM_RBUTTONUP     = ] [ drop 3 f ] }

        { [ dup WM_NCLBUTTONDOWN = ] [ drop 1 t ] }
        { [ dup WM_NCLBUTTONUP   = ] [ drop 1 f ] }
        { [ dup WM_NCMBUTTONDOWN = ] [ drop 2 t ] }
        { [ dup WM_NCMBUTTONUP   = ] [ drop 2 f ] }
        { [ dup WM_NCRBUTTONDOWN = ] [ drop 3 t ] }
        { [ dup WM_NCRBUTTONUP   = ] [ drop 3 f ] }
    } cond ;

! If the user clicks in the window border ("non-client area")
! Windows sends us an NC[LMR]BUTTONDOWN message; but if the
! mouse is subsequently released outside the NC area, we receive
! a [LMR]BUTTONUP message and Factor can get confused. So we
! ignore BUTTONUP's that are a result of an NC*BUTTONDOWN.
SYMBOL: nc-buttons

: handle-wm-ncbutton ( hWnd uMsg wParam lParam -- )
    2drop nip
    message>button nc-buttons get
    swap [ push ] [ delete ] if ;

: >lo-hi ( WORD -- array ) [ lo-word ] keep hi-word 2array ;
: mouse-wheel ( lParam -- array ) >lo-hi [ sgn neg ] map ;

: mouse-absolute>relative ( lparam handle -- array )
    >r >lo-hi r>
    "RECT" <c-object> [ GetWindowRect win32-error=0/f ] keep
    get-RECT-top-left 2array v- ;

: mouse-event>gesture ( uMsg -- button )
    key-modifiers swap message>button
    [ <button-down> ] [ <button-up> ] if ;

: prepare-mouse ( hWnd uMsg wParam lParam -- button coordinate world )
    nip >r mouse-event>gesture r> >lo-hi rot window ;

: set-capture ( hwnd -- )
    mouse-captured get [
        drop
    ] [
        [ SetCapture drop ] keep
        mouse-captured set
    ] if ;

: release-capture ( -- )
    ReleaseCapture win32-error=0/f
    mouse-captured off ;

: handle-wm-buttondown ( hWnd uMsg wParam lParam -- )
    >r >r
    over set-capture
    dup message>button drop nc-buttons get delete
    r> r> prepare-mouse send-button-down ;

: handle-wm-buttonup ( hWnd uMsg wParam lParam -- )
    mouse-captured get [ release-capture ] when
    pick message>button drop dup nc-buttons get member? [
        nc-buttons get delete 4drop
    ] [
        drop prepare-mouse send-button-up
    ] if ;

: make-TRACKMOUSEEVENT ( hWnd -- alien )
    "TRACKMOUSEEVENT" <c-object> [ set-TRACKMOUSEEVENT-hwndTrack ] keep
    "TRACKMOUSEEVENT" heap-size over set-TRACKMOUSEEVENT-cbSize ;

: handle-wm-mousemove ( hWnd uMsg wParam lParam -- )
    2nip
    over make-TRACKMOUSEEVENT
    TME_LEAVE over set-TRACKMOUSEEVENT-dwFlags
    0 over set-TRACKMOUSEEVENT-dwHoverTime
    TrackMouseEvent drop
    >lo-hi swap window move-hand fire-motion ;

: handle-wm-mousewheel ( hWnd uMsg wParam lParam -- )
    >r nip r>
    pick mouse-absolute>relative >r mouse-wheel r> rot window send-wheel ;

: handle-wm-cancelmode ( hWnd uMsg wParam lParam -- )
    #! message sent if windows needs application to stop dragging
    4drop release-capture ;

: handle-wm-mouseleave ( hWnd uMsg wParam lParam -- )
    #! message sent if mouse leaves main application
    4drop forget-rollover ;

SYMBOL: wm-handlers

H{ } clone wm-handlers set-global

: add-wm-handler ( quot wm -- )
    dup array?
    [ [ execute add-wm-handler ] with each ]
    [ wm-handlers get-global set-at ] if ;

[ handle-wm-close 0                  ] WM_CLOSE add-wm-handler
[ 4dup handle-wm-paint DefWindowProc ] WM_PAINT add-wm-handler

[ handle-wm-size 0 ] WM_SIZE add-wm-handler
[ handle-wm-move 0 ] WM_MOVE add-wm-handler

[ 4dup handle-wm-keydown DefWindowProc ] { WM_KEYDOWN WM_SYSKEYDOWN } add-wm-handler
[ 4dup handle-wm-char DefWindowProc    ] { WM_CHAR WM_SYSCHAR }       add-wm-handler
[ 4dup handle-wm-keyup DefWindowProc   ] { WM_KEYUP WM_SYSKEYUP }     add-wm-handler

[ handle-wm-syscommand   ] WM_SYSCOMMAND add-wm-handler
[ handle-wm-set-focus 0  ] WM_SETFOCUS add-wm-handler
[ handle-wm-kill-focus 0 ] WM_KILLFOCUS add-wm-handler

[ handle-wm-buttondown 0 ] WM_LBUTTONDOWN add-wm-handler
[ handle-wm-buttondown 0 ] WM_MBUTTONDOWN add-wm-handler
[ handle-wm-buttondown 0 ] WM_RBUTTONDOWN add-wm-handler
[ handle-wm-buttonup 0   ] WM_LBUTTONUP   add-wm-handler
[ handle-wm-buttonup 0   ] WM_MBUTTONUP   add-wm-handler
[ handle-wm-buttonup 0   ] WM_RBUTTONUP   add-wm-handler

[ 4dup handle-wm-ncbutton DefWindowProc ]
{ WM_NCLBUTTONDOWN WM_NCMBUTTONDOWN WM_NCRBUTTONDOWN
WM_NCLBUTTONUP WM_NCMBUTTONUP WM_NCRBUTTONUP }
add-wm-handler

[ nc-buttons get-global delete-all DefWindowProc ]
{ WM_EXITSIZEMOVE WM_EXITMENULOOP } add-wm-handler

[ handle-wm-mousemove 0  ] WM_MOUSEMOVE  add-wm-handler
[ handle-wm-mousewheel 0 ] WM_MOUSEWHEEL add-wm-handler
[ handle-wm-cancelmode 0 ] WM_CANCELMODE add-wm-handler
[ handle-wm-mouseleave 0 ] WM_MOUSELEAVE add-wm-handler

SYMBOL: trace-messages?

! return 0 if you handle the message, else just let DefWindowProc return its val
: ui-wndproc ( -- object )
    "uint" { "void*" "uint" "long" "long" } "stdcall" [
        [
            pick
            trace-messages? get-global [ dup windows-message-name . ] when
            wm-handlers get-global at* [ call ] [ drop DefWindowProc ] if
        ] ui-try
     ] alien-callback ;

: peek-message? ( msg -- ? ) f 0 0 PM_REMOVE PeekMessage zero? ;

: event-loop ( msg -- )
    {
        { [ windows get empty? ] [ drop ] }
        { [ dup peek-message? ] [ ui-wait event-loop ] }
        { [ dup MSG-message WM_QUIT = ] [ drop ] }
        [
            dup TranslateMessage drop
            dup DispatchMessage drop
            event-loop
        ]
    } cond ;

: register-wndclassex ( -- class )
    "WNDCLASSEX" <c-object>
    f GetModuleHandle
    class-name-ptr get-global
    pick GetClassInfoEx zero? [
        "WNDCLASSEX" heap-size over set-WNDCLASSEX-cbSize
        { CS_HREDRAW CS_VREDRAW CS_OWNDC } flags over set-WNDCLASSEX-style
        ui-wndproc over set-WNDCLASSEX-lpfnWndProc
        0 over set-WNDCLASSEX-cbClsExtra
        0 over set-WNDCLASSEX-cbWndExtra
        f GetModuleHandle over set-WNDCLASSEX-hInstance
        f GetModuleHandle "fraptor" string>u16-alien LoadIcon
        over set-WNDCLASSEX-hIcon
        f IDC_ARROW LoadCursor over set-WNDCLASSEX-hCursor

        class-name-ptr get-global over set-WNDCLASSEX-lpszClassName
        RegisterClassEx dup win32-error=0/f
    ] when ;

: adjust-RECT ( RECT -- )
    style 0 ex-style AdjustWindowRectEx win32-error=0/f ;

: make-RECT ( world -- RECT )
    dup world-loc { 40 40 } vmax dup rot rect-dim v+
    "RECT" <c-object>
    over first over set-RECT-right
    swap second over set-RECT-bottom
    over first over set-RECT-left
    swap second over set-RECT-top ;

: make-adjusted-RECT ( rect -- RECT )
    make-RECT dup adjust-RECT ;

: create-window ( rect -- hwnd )
    make-adjusted-RECT
    >r class-name-ptr get-global f r>
    >r >r >r ex-style r> r>
        { WS_CLIPSIBLINGS WS_CLIPCHILDREN style } flags
    r> get-RECT-dimensions
    f f f GetModuleHandle f CreateWindowEx dup win32-error=0/f ;

: show-window ( hWnd -- )
    dup SW_SHOW ShowWindow drop ! always succeeds
    dup SetForegroundWindow drop
    SetFocus drop ;

: init-win32-ui ( -- )
    V{ } clone nc-buttons set-global
    "MSG" malloc-object msg-obj set-global
    "Factor-window" malloc-u16-string class-name-ptr set-global
    register-wndclassex drop
    GetDoubleClickTime double-click-timeout set-global ;

: cleanup-win32-ui ( -- )
    class-name-ptr get-global [ dup f UnregisterClass drop free ] when*
    msg-obj get-global [ free ] when*
    f class-name-ptr set-global
    f msg-obj set-global ;

: setup-pixel-format ( hdc -- )
    16 make-pfd [ ChoosePixelFormat dup win32-error=0/f ] 2keep
    swapd SetPixelFormat win32-error=0/f ;

: get-dc ( hWnd -- hDC ) GetDC dup win32-error=0/f ;

: get-rc ( hDC -- hRC )
    dup wglCreateContext dup win32-error=0/f
    [ wglMakeCurrent win32-error=0/f ] keep ;

: setup-gl ( hwnd -- hDC hRC )
    get-dc dup setup-pixel-format dup get-rc ;

M: windows-ui-backend (open-window) ( world -- )
    [ create-window dup setup-gl ] keep
    [ f <win> ] keep
    [ swap win-hWnd register-window ] 2keep
    dupd set-world-handle
    win-hWnd show-window ;

M: windows-ui-backend select-gl-context ( handle -- )
    [ win-hDC ] keep win-hRC wglMakeCurrent win32-error=0/f ;

M: windows-ui-backend flush-gl-context ( handle -- )
    win-hDC SwapBuffers win32-error=0/f ;

! Move window to front
M: windows-ui-backend raise-window* ( world -- )
    world-handle [
        win-hWnd SetFocus drop
    ] when* ;

M: windows-ui-backend set-title ( string world -- )
    world-handle
    dup win-title [ free ] when*
    >r malloc-u16-string r>
    2dup set-win-title
    win-hWnd WM_SETTEXT 0 roll alien-address SendMessage drop ;

M: windows-ui-backend ui
    [
        [
            init-clipboard
            init-win32-ui
            start-ui
            msg-obj get event-loop
        ] [ cleanup-win32-ui ] [ ] cleanup
    ] ui-running ;

windows-ui-backend ui-backend set-global

[ "ui" ] main-vocab-hook set-global
