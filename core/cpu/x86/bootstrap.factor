! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts compiler.units math generator.fixup
compiler.constants vocabs ;
IN: bootstrap.x86

big-endian off

1 jit-code-format set

: stack-frame-size 4 bootstrap-cells ;

[
    ! Load word
    temp-reg 0 MOV
    temp-reg dup [] MOV
    ! Bump profiling counter
    temp-reg profile-count-offset [+] 1 tag-fixnum ADD
    ! Load word->code
    temp-reg temp-reg word-code-offset [+] MOV
    ! Compute word XT
    temp-reg compiled-header-size ADD
    ! Jump to XT
    temp-reg JMP
] rc-absolute-cell rt-literal 1 rex-length + jit-profiling jit-define

[
    temp-reg 0 MOV                             ! load XT
    stack-frame-size PUSH                      ! save stack frame size
    temp-reg PUSH                              ! push XT
    arg1 PUSH                                  ! alignment
] rc-absolute-cell rt-label 1 rex-length + jit-prolog jit-define

[
    arg0 0 MOV                                 ! load literal
    arg0 dup [] MOV
    ds-reg bootstrap-cell ADD                  ! increment datastack pointer
    ds-reg [] arg0 MOV                         ! store literal on datastack
] rc-absolute-cell rt-literal 1 rex-length + jit-push-literal jit-define

[
    arg0 0 MOV                                 ! load XT
    arg1 stack-reg MOV                         ! pass callstack pointer as arg 2
    arg0 JMP                                   ! go
] rc-absolute-cell rt-primitive 1 rex-length + jit-primitive jit-define

[
    (JMP) drop
] rc-relative rt-xt 1 jit-word-jump jit-define

[
    (CALL) drop
] rc-relative rt-xt 1 jit-word-call jit-define

[
    arg1 0 MOV                                 ! load addr of true quotation
    arg0 ds-reg [] MOV                         ! load boolean
    ds-reg bootstrap-cell SUB                  ! pop boolean
    arg0 \ f tag-number CMP                    ! compare it with f
    arg0 arg1 [] CMOVNE                        ! load true branch if not equal
    arg0 arg1 bootstrap-cell [+] CMOVE         ! load false branch if equal
    arg0 quot-xt@ [+] JMP                      ! jump to quotation-xt
] rc-absolute-cell rt-literal 1 rex-length + jit-if-jump jit-define

[
    arg1 0 MOV                                 ! load dispatch table
    arg1 dup [] MOV
    arg0 ds-reg [] MOV                         ! load index
    fixnum>slot@                               ! turn it into an array offset
    ds-reg bootstrap-cell SUB                  ! pop index
    arg0 arg1 ADD                              ! compute quotation location
    arg0 arg0 array-start [+] MOV              ! load quotation
    arg0 quot-xt@ [+] JMP                      ! execute branch
] rc-absolute-cell rt-literal 1 rex-length + jit-dispatch jit-define

[
    stack-reg stack-frame-size bootstrap-cell - ADD ! unwind stack frame
] f f f jit-epilog jit-define

[ 0 RET ] f f f jit-return jit-define

[ "bootstrap.x86" forget-vocab ] with-compilation-unit
