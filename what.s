
.globl sys_write_call, cr_call, cr_switch
.globl  _main, init_sched, run_m, new_g
.globl main, cr_schedule

.MACRO SAVE_REG

pushq %rbp;
pushq %rax;
pushq %rbx;
pushq %rcx;
pushq %rdx;

pushq %r8;
pushq %r9;
//  pushq %r10;
pushq %r11
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
popq %r11;
// popq %r10;
popq %r9;
popq %r8;

popq %rdx;
popq %rcx;
popq %rbx;
popq %rax;
popq %rbp;

.ENDM


sys_write_call:

pushq %rdi
pushq %rsi
popq %rdx
popq %rsi
movq $1, %rdi
movq $1, %rax

SAVE_REG

movq %rsp, %rdi;
call cr_schedule

RESTORE_REG
syscall

ret

cr_schedule:

movq %fs:g@tpoff, %rax
leaq 8(%rax), %rbx

movq %rdi, (%rbx)
	movq (%rsp), %rax
	movq %rax, 8(%rbx)
movq $-1,16(%rbx)

	//	switch to g0
	movq %fs:m@tpoff, %rax
	movq (%rax), %rax

	movq (%rax), %rbp
	movq (%rax), %rsp
	call schedule
	ret



	// cr_call(Gobuf *buf, Fn f), call f on buf stack
	// buf in rdi, f in rsi
	cr_call:
	pushq %rbp
	movq %rsp, %rbp

	movq (%rdi), %rax
	movq %rax, %rsp
	movq %rsp, %rbp

	movq %rdi, %rax
	//addq $8, %rax
	movq 8(%rax), %rax
	// push buf.pc
	pushq %rax
	movq %rsi, %rax
	// call f
	jmp *%rax
	ret

	// cr_switch(Gobuf *buf)
	cr_switch:

	movq (%rdi), %rsp
	movq 8(%rdi), %rax

	jmp *%rax

	ret


	main:

	pushq %rbp
	movq %rsp, %rbp

	leaq g0(%rip), %rax
	movq %rax, %fs:g@tpoff
movq %rsp, (%rax)

	leaq m0(%rip), %rbx
	movq %rbx, %fs:m@tpoff
	// g0 -> m.g0
movq %rax,(%rbx)

	call  init_sched

	leaq  _main(%rip), %rdi
	call new_g

	call run_m
	int $3
	ret

