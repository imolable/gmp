.globl  cr_call, write_call, cr_schedule, cr_switch
.globl main

.MACRO SAVE_REG

	pushq %rbp;
	pushq %rax;
	pushq %rbx;
	pushq %rdx;

	pushq %r12;
	pushq %r13;
	pushq %r14;
	pushq %r15;

	pushq %rdi;
	pushq %rsi;

.ENDM

.MACRO RESTORE_REG

	popq %rsi;
	popq %rdi;

	popq %r15;
	popq %r14;
	popq %r13;
	popq %r12;

	popq %rdx;
	popq %rbx;
	popq %rax;
	popq %rbp;

.ENDM


write_call:

	pushq %rdi
	pushq %rsi
	popq %rdx
	popq %rsi
	movq $1, %rdi
	movq $1, %rax

	SAVE_REG

	movq %rsp, %rdi
	call cr_schedule

	RESTORE_REG
	syscall

ret


cr_schedule:

	movq %fs:g@tpoff, %rax
	leaq 8(%rax), %rax

	movq %rdi, (%rax)
	movq (%rsp), %rdx
	movq %rdx, 8(%rax)


	call schedule
ret

// cr_switch(Gobuf *buf)
cr_switch:

	movq (%rdi), %rsp
	movq 8(%rdi), %rax

	jmp *%rax
ret


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

main:

	pushq %rbp
	movq %rsp, %rbp

	leaq m0(%rip), %rbx
	movq %rbx, %fs:m@tpoff

	call init_sched
	leaq  _main(%rip), %rdi
	call new_g

	call schedule
	int $3
ret
