.globl  cr_call


// cr_call(Gobuf *buf, Fn f), call f on buf's stack
// buf in rdi, f in rsi
cr_call:

movq %rbp, %r10
movq %rsp, %r11

movq (%rdi), %rax
movq %rax, %rsp
movq %rsp, %rbp

pushq %r11
pushq %r10

movq %rsi, %rax
// call f
call *%rax

popq %rbp
popq %rsp

ret
