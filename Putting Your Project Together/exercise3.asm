	.data
playerRow:	.word 1
playerColumn:	.word 3
	
	.text

main:

gameloop:
	# Sleep for 2 seconds
	li	$a0, 60
	li	$v0, 32
	syscall
	# Check for input
	la	$t1, 0xffff0000
	lw	$t2, ($t1)
	beq	$t2, 1, input_available
	j gameloop
	
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
	lw	$a0, playerRow
	lw	$a1, playerColumn
	add	$a2, $a0, $s0
	add	$a3, $a1, $s1
	# Call move function
	j gameloop

pressed_z:
	li	$s0, 0
	li	$s1, 1
	j handled_input
pressed_s:
	li	$s0, 0
	li	$s1, -1
	j handled_input
pressed_q:
	li	$s0, -1
	li	$s1, 0
	j handled_input
pressed_d:
	li	$s0, 1
	li	$s1, 0
	j handled_input
pressed_x:
	j exit

exit:
	# Terminate program
	li	$v0, 10
	syscall
	