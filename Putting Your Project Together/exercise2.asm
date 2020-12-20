	.data
width:		.word 8
height:		.word 8
blue:		.word 0x000000ff
black:		.word 0x00000000
yellow:		.word 0x00ffff00
green:		.word 0x0000ff00

	.text

main:
	li	$a0, 0
	li	$a1, 6
	li	$a2, -1
	li	$a3, 6
	jal update_player_position
	move	$a0, $v0
	move	$t0, $v1
	jal print_int
	move	$a0, $t0
	jal print_int
	j exit

# Updates player position
# Parameters:
#	a0: current player row
#	a1: current player column
#	a2: new player row
#	a3: new player column
# Returns:
#	v0: actual new row
#	v1: actual new column
update_player_position:
	addi	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s1, 20($sp)
	sw	$s0, 16($sp)
	sw	$a3, 12($sp)
	sw	$a2, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
	move	$t0, $a0
	move	$t1, $a1
	# Check min size
	move	$v0, $t0
	move	$v1, $t1
	bgtu	$a0, 0, update_player_restore
	bgtu	$a1, 0, update_player_restore
	# Current player position address
	jal 	coords_to_address
	move	$s0, $v0
	# New player position address
	move	$a0, $a2
	move	$a1, $a3
	jal 	coords_to_address
	move	$s1, $v0
	# Check max size
	lw	$t0, width
	lw	$t1, height
	bgeu	$a0, $t1, update_player_restore
	bgeu	$a1, $t0, update_player_restore
	lw	$t3, ($s1)
	lw	$t4, blue
	beq	$t3, $t4, update_player_restore # new spot is wall
	lw	$t5, green
	beq	$t3, $t4, player_won # new spot is destination
	move	$v0, $a0
	move	$v1, $a1
	# Color pixels if position is valid
	lw	$t1, black
	sw	$t1, ($s0)
	lw	$t1, yellow
	sw	$t1, ($s1)
update_player_restore:
	# Restore values
	lw	$ra, 24($sp)
	lw	$s1, 20($sp)
	lw	$s0, 16($sp)
	lw	$a3, 12($sp)
	lw	$a2, 8($sp)
	lw	$a1, 4($sp)
	lw	$a0, 0($sp)
	addi	$sp, $sp, 28
	jr	$ra

player_won:
	li 	$a0, 6969
	jal	print_int
	j 	exit

# Map row and column to an address
# Parameters:
#	a0: row
#	a1: column
# Returns:
#	v0: address
coords_to_address:
	# Load width and store y * 512 in register t0
	lw 	$t0, width
	mult 	$a0, $t0
	mflo	$t0
	# Add x
	addu 	$t0, $t0, $a1
	# Multiply by 4
	sll	$t0, $t0, 2
	# Add the result by the gp (bitmap start) address
	addu	$v0, $gp, $t0
	# Jump back
	jr	$ra

# Prints a string
# Parameters:
#	a0: string; value to print
print_int:
	li 	$v0,  1
	syscall
	jr	$ra

# Terminates program
exit:
	li	$v0, 10
	syscall