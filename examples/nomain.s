.global main

main:
pushq %rbp
movq %rsp, %rbp

movq $10, bb(%rip)
	call print_hello

	leave
	ret
