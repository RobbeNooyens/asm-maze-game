	.data
 newline: .asciiz "\n"
 
	.text
main:
	# i = 1
	li $t0, 1
	j loop

loop:
	# Exit loop if i <= 11
	bge $t0, 11, exit
	# Print i
	la	$a0, ($t0)
	li	$v0, 1
	syscall
	# Print newline
	la	$a0, newline 	# load the addr of hello_msg into $a0.
	li 	$v0, 4		# load code for print_string
	syscall
	# i++
	addi $t0, $t0, 1
	j loop

exit:
	# Terminate program
	li	$v0, 10
	syscall
