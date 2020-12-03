	.data
prime_msg: .asciiz "Prime"
no_prime_msg: .asciiz "No prime"
	.text

main:
	# Set default variables
	li	$t1, 2
	li	$t2, 1
	# Ask a number
	li	$v0, 5
	syscall
	move	$t0, $v0
	# Branch to prime if number is 1
	beq 	$t0, 1, prime
	j loop

loop:
	# Number is not prime if it has a divider
	beq 	$t2, 0, no_prime
	# Number is a prime if it has no divider between 1 and the number itself exclusive
	beq 	$t1, $t0, prime
	# Copy register t0
	add $t4, $zero, $t0
	# Divide the number by i
	div 	$t0, $t1
	# Move the remainder of the division, stored in mfhi, in register t2
	mfhi 	$t2
	# i++
	addi 	$t1, $t1, 1
	j loop

prime:
	# Print 'Prime'
	la	$a0, prime_msg
	li 	$v0, 4
	syscall
	j exit

no_prime:
	# Print 'No prime'
	la	$a0, no_prime_msg
	li 	$v0, 4
	syscall
	j exit

exit:
	# Terminate program
	li	$v0, 10
	syscall