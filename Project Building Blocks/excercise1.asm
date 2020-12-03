	.data
width: .half 512
height: .half 512

	.text
main:
	# Read x
	li $v0, 5
	syscall
	# Move x to a0
	move $a0, $v0
	# Read y
	li $v0, 5
	syscall
	# Move y to a1
	move $a1, $v0
	# Call function
	jal coords_to_address
	# Print function result
	la $a0, ($v0)
	li $v0, 1
	syscall
	# Terminate program
	li $v0, 10
	syscall

coords_to_address:
	# x = a0
	# y = a1
	# Load width and store y * 512 in register t0
	lw 	$t0, width
	mult 	$a1, $t0
	mflo	$t0
	# Add x
	addu 	$t0, $t0, $a0
	# Multiply by 4
	sll	$t0, $t0, 2
	# Add the result by the gp (bitmap start) address
	addu	$v0, $gp, $t0
	# Jump back
	jr	$ra