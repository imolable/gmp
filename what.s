.global add
.global sys_write_call

add:
movl %edi, %eax
addl %esi, %eax
ret

sys_write_call:

pushq %rdi
pushq %rsi
popq %rdx
popq %rsi
movq $1, %rdi
movq $1, %rax
syscall
ret
