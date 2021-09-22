	.file	"_thread.c"
	.text
	.globl	pm
	.section	.tbss,"awT",@nobits
	.align 8
	.type	pm, @object
	.size	pm, 8
pm:
	.zero	8
	.section	.rodata
.LC0:
	.string	"--- m.a %d, %d, %d \n"
	.text
	.globl	routine
	.type	routine, @function
routine:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$3, -20(%rbp)
	movl	$4, -16(%rbp)
	movl	$5, -12(%rbp)
	leaq	-20(%rbp), %rax
	movq	%rax, %fs:pm@tpoff
	movq	%fs:pm@tpoff, %rax
	movl	8(%rax), %ecx
	movq	%fs:pm@tpoff, %rax
	movl	4(%rax), %edx
	movq	%fs:pm@tpoff, %rax
	movl	(%rax), %eax
	movl	%eax, %esi
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	nop
	movq	-8(%rbp), %rsi
	subq	%fs:40, %rsi
	je	.L2
	call	__stack_chk_fail@PLT
.L2:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	routine, .-routine
	.section	.rodata
.LC1:
	.string	"m.a %d, %d, %d \n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$1, -20(%rbp)
	movl	$10, -16(%rbp)
	movl	$100, -12(%rbp)
	leaq	-20(%rbp), %rax
	movq	%rax, %fs:pm@tpoff
	movq	%fs:pm@tpoff, %rax
	movl	8(%rax), %ecx
	movq	%fs:pm@tpoff, %rax
	movl	4(%rax), %edx
	movq	%fs:pm@tpoff, %rax
	movl	(%rax), %eax
	movl	%eax, %esi
	leaq	.LC1(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$1, %edi
	call	sleep@PLT
	leaq	-32(%rbp), %rax
	movl	$0, %ecx
	leaq	routine(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movl	$1, %edi
	call	sleep@PLT
	movq	%fs:pm@tpoff, %rax
	movl	8(%rax), %ecx
	movq	%fs:pm@tpoff, %rax
	movl	4(%rax), %edx
	movq	%fs:pm@tpoff, %rax
	movl	(%rax), %eax
	movl	%eax, %esi
	leaq	.LC1(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	movq	-8(%rbp), %rsi
	subq	%fs:40, %rsi
	je	.L5
	call	__stack_chk_fail@PLT
.L5:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 10.3.0-1ubuntu1) 10.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
