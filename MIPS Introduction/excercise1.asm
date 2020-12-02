	.data
msg_1:	.asciiz "This is my "
msg_2:	.asciiz	"-th MIPS-program./n"

	.text

main:
	li 	$v0, 5
	syscall
	move	$t0, $v0
	la	$a0, msg_1 	# load the addr of hello_msg into $a0.
	li 	$v0, 4		# load code for print_string
	syscall
	la	$a0, ($t0)
	li	$v0, 1
	syscall
	la	$a0, msg_2 	# load the addr of hello_msg into $a0.
	li 	$v0, 4		# load code for print_string
	syscall

exit:
	li	$v0, 10		# load code for exit
	syscall
