
.globl sys_write_call
.globl cr, print_int,schedule, save_g_sp, _switch_to

.MACRO SAVE_REG
    pushq %rbp;
	pushq %rax;
    pushq %rbx;
    pushq %rcx;
	pushq %rdx;
    /*
    pushq %r8; 
    pushq %r9; 
    pushq %r10;
    pushq %r11 
    pushq %r12; 
    pushq %r13; 
    pushq %r14; 
    pushq %r15; 
    */      
	pushq %rdi;       
	pushq %rsi;            
	movq %rsp, %rdi; 
	call save_g_sp;
.ENDM

.MACRO RESTORE_REG
	popq %rsi;
    popq %rdi;
    /*
    popq %r15;
    popq %r14;
    popq %r13;
    popq %r12;
    popq %r11;
    popq %r10;
    popq %r9;
    popq %r8;
    */
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
call switch_to

syscall

ret

// cr(Gobuf *buf, Fn f), call f on buf stack
// buf in rdi, f in rsi
cr:

movq (%rdi), %rax
movq %rax, %rbp
movq %rax, %rsp

movq %rdi, %rax
addq $8, %rax
movq (%rax), %rax
// push buf.exit
pushq %rax 
// call f
call *%rsi 

ret

// switch_to(Gobuf *buf)
_switch_to:

movq (%rdi), %rsp
RESTORE_REG

ret

