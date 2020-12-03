	.data
 space: .asciiz " "
 newline: .asciiz "\n"
 
	.text
main:
	# Read number
	li $v0, 5
	syscall
	# Save the integer in register t0
	move $t0, $v0
	# i = 0
	li $t1, 0
	j loop

loop:
	# i++
	addi 	$t1, $t1, 1
	# if (i > number) => exit
	bgt 	$t1, $t0, exit
	# j = 1
	li 	$t2, 1
	j printline

printline:
	# Stop loop if j > i
	bgt 	$t2, $t1, printed
	# Print j
	li	$v0, 1
	la	$a0, ($t2)
	syscall
	# j++
	addi	$t2, $t2, 1
	# Print space
	li 	$v0, 4
	la	$a0, space
	syscall
	j printline

printed:
	# Print newline
	li 	$v0, 4
	la	$a0, newline
	syscall
	j loop
	
exit:
	# Terminate program
	li	$v0, 10
	syscall
