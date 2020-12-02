	.data
 newline: .asciiz "\n"
	.text

main:
	li $t0, 1
	j loop

loop:
	bge $t0, 11, exit
	la	$a0, ($t0)
	li	$v0, 1
	syscall
	la	$a0, newline 	# load the addr of hello_msg into $a0.
	li 	$v0, 4		# load code for print_string
	syscall
	addi $t0, $t0, 1
	j loop
exit:
	