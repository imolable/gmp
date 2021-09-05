.global print_hello, print_int, print_add, call_asm, sub

call_asm:
//pushq %rbp
//movq %rsp, %rbp


//call print_hello
//movq $10, 16(%rsp)

//call print_hello
call *%rdi
movq $1, %rax

///popq %rbp
//leave
ret
