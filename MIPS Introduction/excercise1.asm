	.data
msg_1:	.asciiz "This is my "
msg_2:	.asciiz	"-th MIPS-program./n"

	.text

main:
	# Read number
	li 	$v0, 5
	syscall
	# Move number to register t0
	move	$t0, $v0
	# Print first substring
	la	$a0, msg_1
	li 	$v0, 4
	syscall
	# Print number
	la	$a0, ($t0)
	li	$v0, 1
	syscall
	# Print second substring
	la	$a0, msg_2
	li 	$v0, 4
	syscall

exit:
	# Terminate program
	li	$v0, 10
	syscall
