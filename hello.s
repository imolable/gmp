.globl  cr_call


// cr_call(Gobuf *buf, Fn f), call f on buf's stack
// buf in rdi, f in rsi
cr_call:

movq (%rdi), %rax
movq %rax, %rsp
movq %rsp, %rbp

// push buf.pc
movq 8(%rdi), %rax
pushq %rax

movq %rsi, %rax
// call f
jmp *%rax


ret
