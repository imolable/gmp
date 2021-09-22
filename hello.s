	.file	"hello.c"
	.text
	.globl	enqueue
	.type	enqueue, @function
enqueue:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-8(%rbp), %rax
	movl	16(%rax), %eax
	testl	%eax, %eax
	jne	.L2
	movq	-8(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-8(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, 8(%rax)
	movq	-8(%rbp), %rax
	movl	$1, 16(%rax)
	jmp	.L4
.L2:
	movq	-8(%rbp), %rax
	movq	8(%rax), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, 40(%rax)
	movq	-8(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, 8(%rax)
	movq	-16(%rbp), %rax
	movq	$0, 40(%rax)
	movq	-8(%rbp), %rax
	movl	16(%rax), %eax
	leal	1(%rax), %edx
	movq	-8(%rbp), %rax
	movl	%edx, 16(%rax)
.L4:
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	enqueue, .-enqueue
	.globl	dequeue
	.type	dequeue, @function
dequeue:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L6
	movq	-8(%rbp), %rax
	movq	40(%rax), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, (%rax)
	movq	-24(%rbp), %rax
	movl	16(%rax), %eax
	leal	-1(%rax), %edx
	movq	-24(%rbp), %rax
	movl	%edx, 16(%rax)
.L6:
	movq	-8(%rbp), %rax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	dequeue, .-dequeue
	.globl	sched
	.bss
	.align 32
	.type	sched, @object
	.size	sched, 128
sched:
	.zero	128
	.globl	m
	.section	.tbss,"awT",@nobits
	.align 8
	.type	m, @object
	.size	m, 8
m:
	.zero	8
	.globl	g
	.align 8
	.type	g, @object
	.size	g, 8
g:
	.zero	8
	.globl	m0
	.bss
	.align 16
	.type	m0, @object
	.size	m0, 24
m0:
	.zero	24
	.globl	g0
	.align 32
	.type	g0, @object
	.size	g0, 56
g0:
	.zero	56
	.section	.rodata
.LC0:
	.string	" ... get g from local"
.LC1:
	.string	" ... get g from global"
	.text
	.globl	get_g
	.type	get_g, @function
get_g:
.LFB8:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	dequeue
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L9
	leaq	.LC0(%rip), %rdi
	call	puts@PLT
	movq	-8(%rbp), %rax
	jmp	.L10
.L9:
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	leaq	40+sched(%rip), %rdi
	call	pthread_mutex_lock@PLT
	movl	$0, -20(%rbp)
	jmp	.L11
.L17:
	leaq	8+sched(%rip), %rdi
	call	dequeue
	movq	%rax, -16(%rbp)
	jmp	.L12
.L14:
	leaq	40+sched(%rip), %rsi
	leaq	80+sched(%rip), %rdi
	call	pthread_cond_wait@PLT
	leaq	8+sched(%rip), %rdi
	call	dequeue
	movq	%rax, -16(%rbp)
.L12:
	cmpq	$0, -16(%rbp)
	jne	.L13
	cmpl	$0, -20(%rbp)
	je	.L14
.L13:
	cmpq	$0, -16(%rbp)
	je	.L18
	movq	-40(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	enqueue
	addl	$1, -20(%rbp)
.L11:
	cmpl	$1, -20(%rbp)
	jle	.L17
	jmp	.L16
.L18:
	nop
.L16:
	leaq	40+sched(%rip), %rdi
	call	pthread_mutex_unlock@PLT
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	dequeue
.L10:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	get_g, .-get_g
	.section	.rodata
.LC2:
	.string	"-- put local ...."
.LC3:
	.string	"-- put global ...."
	.text
	.globl	put_g
	.type	put_g, @function
put_g:
.LFB9:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	-24(%rbp), %rax
	movl	16(%rax), %eax
	cmpl	$1, %eax
	jg	.L20
	movq	-24(%rbp), %rax
	movq	-32(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	enqueue
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	jmp	.L19
.L20:
	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	leaq	40+sched(%rip), %rdi
	call	pthread_mutex_lock@PLT
	movq	-32(%rbp), %rax
	movq	%rax, %rsi
	leaq	8+sched(%rip), %rdi
	call	enqueue
	leaq	80+sched(%rip), %rdi
	call	pthread_cond_signal@PLT
	leaq	40+sched(%rip), %rdi
	call	pthread_mutex_unlock@PLT
	movl	$0, %eax
	call	get_idle_p
	movq	%rax, -8(%rbp)
	cmpq	$0, -24(%rbp)
	je	.L19
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	new_m
.L19:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	put_g, .-put_g
	.section	.rodata
.LC4:
	.string	" --- g is null, sleep "
	.text
	.globl	schedule
	.type	schedule, @function
schedule:
.LFB10:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%fs:m@tpoff, %rax
	movq	8(%rax), %rax
	movq	%rax, -16(%rbp)
	movq	%fs:g@tpoff, %rax
	testq	%rax, %rax
	je	.L23
	movq	%fs:g@tpoff, %rax
	movl	48(%rax), %eax
	cmpl	$1, %eax
	jne	.L23
	movq	%fs:g@tpoff, %rax
	movl	$0, 48(%rax)
	movq	%fs:g@tpoff, %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	put_g
.L23:
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	get_g
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L24
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
	movl	$10, %edi
	call	sleep@PLT
	movl	$0, %eax
	jmp	.L25
.L24:
	movq	-8(%rbp), %rax
	movl	$1, 48(%rax)
	movq	-8(%rbp), %rax
	movq	%rax, %fs:g@tpoff
	movq	%fs:g@tpoff, %rax
	movq	16(%rax), %rax
	leaq	gexit(%rip), %rdx
	cmpq	%rdx, %rax
	jne	.L26
	movq	%fs:g@tpoff, %rax
	movq	32(%rax), %rax
	movq	%fs:g@tpoff, %rdx
	addq	$8, %rdx
	movq	%rax, %rsi
	movq	%rdx, %rdi
	call	cr@PLT
.L26:
	movq	%fs:g@tpoff, %rax
	addq	$8, %rax
	movq	%rax, %rdi
	call	_switch_to@PLT
	movl	$0, %eax
.L25:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	schedule, .-schedule
	.section	.rodata
.LC5:
	.string	"--- g dead --- "
	.text
	.globl	gexit
	.type	gexit, @function
gexit:
.LFB11:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%fs:g@tpoff, %rax
	movl	$2, 48(%rax)
	leaq	.LC5(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	schedule
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	gexit, .-gexit
	.section	.rodata
.LC6:
	.string	"AA_%d\n"
.LC7:
	.string	"AA: m->debug: %d \n"
	.text
	.globl	print_a
	.type	print_a, @function
print_a:
.LFB12:
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
	movl	$0, -24(%rbp)
	jmp	.L30
.L31:
	movl	-24(%rbp), %edx
	leaq	-18(%rbp), %rax
	leaq	.LC6(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf@PLT
	leaq	-18(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movl	%eax, %edx
	leaq	-18(%rbp), %rax
	movl	%edx, %esi
	movq	%rax, %rdi
	call	sys_write_call@PLT
	movq	%fs:m@tpoff, %rax
	movl	16(%rax), %eax
	movl	%eax, %esi
	leaq	.LC7(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -24(%rbp)
.L30:
	cmpl	$9, -24(%rbp)
	jle	.L31
	nop
	movq	-8(%rbp), %rax
	subq	%fs:40, %rax
	je	.L32
	call	__stack_chk_fail@PLT
.L32:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	print_a, .-print_a
	.section	.rodata
.LC8:
	.string	"BBB_%d\n"
.LC9:
	.string	"BB: m->debug: %d \n"
	.text
	.globl	print_b
	.type	print_b, @function
print_b:
.LFB13:
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
	movl	$0, -24(%rbp)
	jmp	.L34
.L35:
	movl	-24(%rbp), %edx
	leaq	-18(%rbp), %rax
	leaq	.LC8(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf@PLT
	leaq	-18(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movl	%eax, %edx
	leaq	-18(%rbp), %rax
	movl	%edx, %esi
	movq	%rax, %rdi
	call	sys_write_call@PLT
	movq	%fs:m@tpoff, %rax
	movl	16(%rax), %eax
	movl	%eax, %esi
	leaq	.LC9(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -24(%rbp)
.L34:
	cmpl	$19, -24(%rbp)
	jle	.L35
	nop
	movq	-8(%rbp), %rax
	subq	%fs:40, %rax
	je	.L36
	call	__stack_chk_fail@PLT
.L36:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	print_b, .-print_b
	.section	.rodata
.LC10:
	.string	"CCCC_%d\n"
.LC11:
	.string	"CC: m->debug: %d \n"
	.text
	.globl	print_c
	.type	print_c, @function
print_c:
.LFB14:
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
	movl	$0, -24(%rbp)
	jmp	.L38
.L39:
	movl	-24(%rbp), %edx
	leaq	-18(%rbp), %rax
	leaq	.LC10(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf@PLT
	leaq	-18(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movl	%eax, %edx
	leaq	-18(%rbp), %rax
	movl	%edx, %esi
	movq	%rax, %rdi
	call	sys_write_call@PLT
	movq	%fs:m@tpoff, %rax
	movl	16(%rax), %eax
	movl	%eax, %esi
	leaq	.LC11(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -24(%rbp)
.L38:
	cmpl	$14, -24(%rbp)
	jle	.L39
	nop
	movq	-8(%rbp), %rax
	subq	%fs:40, %rax
	je	.L40
	call	__stack_chk_fail@PLT
.L40:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	print_c, .-print_c
	.section	.rodata
.LC12:
	.string	"=== New === "
	.text
	.globl	print_d
	.type	print_d, @function
print_d:
.LFB15:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC12(%rip), %rdi
	call	puts@PLT
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	print_d, .-print_d
	.section	.rodata
.LC13:
	.string	"==== addr: %p \n"
	.text
	.globl	print_addr
	.type	print_addr, @function
print_addr:
.LFB16:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC13(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	print_addr, .-print_addr
	.globl	malloc_g
	.type	malloc_g, @function
malloc_g:
.LFB17:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movl	$56, %edi
	call	malloc@PLT
	movq	%rax, -16(%rbp)
	movl	-20(%rbp), %eax
	cltq
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	movl	-20(%rbp), %eax
	movslq	%eax, %rdx
	movq	-8(%rbp), %rax
	addq	%rax, %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, (%rax)
	movq	-16(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	malloc_g, .-malloc_g
	.globl	get_g_id
	.type	get_g_id, @function
get_g_id:
.LFB18:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	i.0(%rip), %eax
	addl	$1, %eax
	movl	%eax, i.0(%rip)
	movl	i.0(%rip), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE18:
	.size	get_g_id, .-get_g_id
	.globl	new_g
	.type	new_g, @function
new_g:
.LFB19:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movl	$8192, %edi
	call	malloc_g
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	-24(%rbp), %rdx
	movq	%rdx, 32(%rax)
	movq	-8(%rbp), %rax
	movq	(%rax), %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, 8(%rax)
	movq	-8(%rbp), %rax
	leaq	gexit(%rip), %rdx
	movq	%rdx, 16(%rax)
	movq	-8(%rbp), %rax
	movl	$0, 48(%rax)
	movl	$0, %eax
	call	get_g_id
	movq	-8(%rbp), %rdx
	movl	%eax, 52(%rdx)
	movq	%fs:m@tpoff, %rax
	movq	8(%rax), %rax
	movq	-8(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	put_g
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE19:
	.size	new_g, .-new_g
	.section	.rodata
.LC14:
	.string	" ---- hello --- "
	.text
	.globl	print_hello
	.type	print_hello, @function
print_hello:
.LFB20:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC14(%rip), %rdi
	call	puts@PLT
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE20:
	.size	print_hello, .-print_hello
	.globl	new_p
	.type	new_p, @function
new_p:
.LFB21:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$120, %edi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	$0, 16(%rax)
	movq	-8(%rbp), %rax
	addq	$32, %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_mutex_init@PLT
	movq	-8(%rbp), %rax
	addq	$72, %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_cond_init@PLT
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE21:
	.size	new_p, .-new_p
	.globl	init_sched
	.type	init_sched, @function
init_sched:
.LFB22:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	movq	%fs:m@tpoff, %rbx
	movl	$0, %eax
	call	new_p
	movq	%rax, 8(%rbx)
	movl	$1, -28(%rbp)
	jmp	.L52
.L53:
	movl	$0, %eax
	call	new_p
	movq	%rax, -24(%rbp)
	movq	sched(%rip), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, 24(%rax)
	movq	-24(%rbp), %rax
	movq	%rax, sched(%rip)
	addl	$1, -28(%rbp)
.L52:
	cmpl	$1, -28(%rbp)
	jle	.L53
	movl	$0, %esi
	leaq	40+sched(%rip), %rdi
	call	pthread_mutex_init@PLT
	movl	$0, %esi
	leaq	80+sched(%rip), %rdi
	call	pthread_cond_init@PLT
	nop
	movq	-8(%rbp), %rbx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE22:
	.size	init_sched, .-init_sched
	.globl	get_idle_p
	.type	get_idle_p, @function
get_idle_p:
.LFB23:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	leaq	40+sched(%rip), %rdi
	call	pthread_mutex_lock@PLT
	movq	sched(%rip), %rax
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L55
	movq	-8(%rbp), %rax
	movq	24(%rax), %rax
	movq	%rax, sched(%rip)
.L55:
	leaq	40+sched(%rip), %rdi
	call	pthread_mutex_unlock@PLT
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE23:
	.size	get_idle_p, .-get_idle_p
	.globl	start_m
	.type	start_m, @function
start_m:
.LFB24:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %fs:m@tpoff
	movl	$0, %eax
	call	schedule
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE24:
	.size	start_m, .-start_m
	.section	.rodata
.LC15:
	.string	"bad run"
	.text
	.globl	run_m
	.type	run_m, @function
run_m:
.LFB25:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%fs:m@tpoff, %rax
	movq	(%rax), %rdx
	movq	%fs:g@tpoff, %rax
	cmpq	%rax, %rdx
	je	.L59
	leaq	.LC15(%rip), %rdi
	call	puts@PLT
	movl	$-1, %edi
	call	exit@PLT
.L59:
	movl	$0, %eax
	call	schedule
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE25:
	.size	run_m, .-run_m
	.globl	clone_start
	.type	clone_start, @function
clone_start:
.LFB26:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %fs:m@tpoff
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, %fs:g@tpoff
	movl	$0, %eax
	call	run_m
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE26:
	.size	clone_start, .-clone_start
	.section	.rodata
.LC16:
	.string	"clone failed"
	.text
	.globl	new_m
	.type	new_m, @function
new_m:
.LFB27:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movl	$24, %edi
	call	malloc@PLT
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	-40(%rbp), %rdx
	movq	%rdx, 8(%rax)
	movq	-16(%rbp), %rax
	movl	$10, 16(%rax)
	movl	$8192, -24(%rbp)
	movl	-24(%rbp), %eax
	movl	%eax, %edi
	call	malloc_g
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	-8(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, %rcx
	movl	$67840, %edx
	movq	%rax, %rsi
	leaq	clone_start(%rip), %rdi
	movl	$0, %eax
	call	clone@PLT
	movl	%eax, -20(%rbp)
	cmpl	$-1, -20(%rbp)
	jne	.L64
	leaq	.LC16(%rip), %rdi
	call	puts@PLT
	movl	$-1, %edi
	call	exit@PLT
.L64:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE27:
	.size	new_m, .-new_m
	.globl	switch_to_g0_call
	.type	switch_to_g0_call, @function
switch_to_g0_call:
.LFB28:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE28:
	.size	switch_to_g0_call, .-switch_to_g0_call
	.section	.rodata
.LC17:
	.string	"G size: %d \n"
.LC18:
	.string	"main done! "
	.text
	.globl	_main
	.type	_main, @function
_main:
.LFB29:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$56, %esi
	leaq	.LC17(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	print_a(%rip), %rdi
	call	new_g
	leaq	print_b(%rip), %rdi
	call	new_g
	leaq	print_c(%rip), %rdi
	call	new_g
	leaq	.LC18(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE29:
	.size	_main, .-_main
	.local	i.0
	.comm	i.0,4,4
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
