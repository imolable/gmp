	.file	"nomain.c"
	.text
	.globl	bb
	.bss
	.align 4
	.type	bb, @object
	.size	bb, 4
bb:
	.zero	4
	.globl	aa
	.data
	.align 4
	.type	aa, @object
	.size	aa, 4
aa:
	.long	22
	.globl	cc
	.align 4
	.type	cc, @object
	.size	cc, 4
cc:
	.long	33
	.globl	ap
	.bss
	.align 8
	.type	ap, @object
	.size	ap, 8
ap:
	.zero	8
	.globl	fn
	.align 8
	.type	fn, @object
	.size	fn, 8
fn:
	.zero	8
	.text
	.globl	get_bb
	.type	get_bb, @function
get_bb:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	aa(%rip), %rax
	movq	%rax, -16(%rbp)
	leaq	cc(%rip), %rax
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, ap(%rip)
	leaq	bb(%rip), %rax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	get_bb, .-get_bb
	.globl	getbb
	.type	getbb, @function
getbb:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	get_bb(%rip), %rax
	movq	%rax, fn(%rip)
	movl	bb(%rip), %edx
	movl	aa(%rip), %eax
	addl	%eax, %edx
	movl	cc(%rip), %eax
	addl	%edx, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	getbb, .-getbb
	.section	.rodata
.LC0:
	.string	"hello world:%d\n"
	.text
	.globl	print_hello
	.type	print_hello, @function
print_hello:
.LFB8:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	bb(%rip), %eax
	movl	%eax, %esi
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	print_hello, .-print_hello
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
