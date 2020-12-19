	.data
enter_char:	.asciiz "Please enter a character\n"
directions:	.asciiz "up\n", "down\n", "left\n", "right\n"
	.text
main:
	# Move x (not needed yet but useful for later)
	li	$s0, 1
	# Move y (not needed yet but useful for later)
	li	$s1, 0
	j loop

loop:
	# Sleep for 2 seconds
	li	$a0, 2000
	li	$v0, 32
	syscall
	# Check for input
	la	$t1, 0xffff0000
	lw	$t2, ($t1)
	beq	$t2, 1, input_available
no_input_available:
	# Print enter character message
	la	$a0, enter_char
	li	$v0, 4
	syscall
	j loop
input_available:
	# Load latest character
	la	$t1, 0xffff0004
	lw	$t2, ($t1)
	# Switch latest character
	beq	$t2, 119, pressed_z
	beq	$t2, 97, pressed_q
	beq	$t2, 115, pressed_s
	beq	$t2, 100, pressed_d
	beq	$t2, 120, pressed_x
handled_input:
	# Executed when press event has been handled
	j loop

pressed_z:
	li	$s0, 0
	li	$s0, 1
	la	$a0, directions+0
	li	$v0, 4
	syscall
	j handled_input
pressed_s:
	li	$s0, 0
	li	$s0, -1
	la	$a0, directions+4
	li	$v0, 4
	syscall
	j handled_input
pressed_q:
	li	$s0, -1
	li	$s0, 0
	la	$a0, directions+10
	li	$v0, 4
	syscall
	j handled_input
pressed_d:
	li	$s0, 1
	li	$s0, 0
	la	$a0, directions+16
	li	$v0, 4
	syscall
	j handled_input
pressed_x:
	j exit

exit:
	# Terminate program
	li	$v0, 10
	syscall

