	.data
exitRow:	.word 0
exitColumn:	.word 0
playerRow:	.word 0
playerColumn:	.word 0
victory:	.asciiz "Victory"

	.text

main:
	jal dfs

# Finds exit recursively
# Parameters:
#	$a0: location_row
#	$a1: location_col
#	$a2: visited base pointer
#	$a3: visited size
dfs:
	# Prepare array copy
	move	$t0, $a3
	move	$t1, $a2
	addiu	$a3, $a3, 1
	subu	$sp, $sp, $a3
	move	$t2, $sp
copy:
	# Copy array to current stackframe
	lw	$t3, ($t1)
	sw	$t3, ($t2)
	addiu	$t1, $t1, 4
	addiu	$t2, $t2, 4
	subiu	$t0, $t0, 1
	bne	$t0, $zero, copy
	# Save other values
	subiu	$sp, $sp, 20
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$a2, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
	
	li	$t7, 1000
	jal	sleep
	
	# Check if player reached the finish
	lw	$t0, exitRow
	lw	$t1, exitColumn
	bne	$a0, $t0, not_on_finish
	bne	$a1, $t1, not_on_finish
	lw	$v0, victory
	j	exit_dfs
not_on_finish:
	li	$a0, -1
	li	$a1, 0
	jal	dfs_loop_move
	li	$a0, 1
	li	$a1, 0
	jal	dfs_loop_move
	li	$a0, 0
	li	$a1, -1
	jal	dfs_loop_move
	li	$a0, 0
	li	$a1, -1
	jal	dfs_loop_move
exit_dfs:
	lw	$ra, 16($sp)
	lw	$a3, 12($sp)
	lw	$a2, 8($sp)
	lw	$a1, 4($sp)
	lw	$a0, 0($sp)
	addiu	$sp, $sp, 20
	addu	$sp, $sp, $a3
	jr	$ra

# One iteration for the for loop
# Parameters:
#	a0: addRow
#	a1: addColumn
#	a2: visited base pointer
#	a3: visited array size
dfs_loop_move:
	# Save values
	subiu	$sp, $sp, 20
	sw	$ra, 16($sp)
	sw	$ra, 12($sp)
	sw	$a2, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
	# Load current player coordinates
	lw	$s0, playerRow
	lw	$s1, playerColumn
	# Load next coordinates
	add	$s2, $a0, $s0
	add	$s3, $a1, $s1
	move	$s4, $a2
	move	$s5, $a3
	# Calculate target address
	move	$a0, $s2
	move	$a1, $s3
	jal	coords_to_address
	move	$s6, $v0
	move	$a1, $v0
	move	$a0, $a2
	jal	already_visited
	beq	$v0, 1, dfs_loop_move_return
	# Not yet visited
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $s3
	# Move player to new location
	jal update_player_position
	move	$s2, $v0
	move	$s3, $v1
	
	# Exit if from and to are the same square
	bne	$v0, $s0, dfs_loop_move_recursive_call
	beq	$v1, $s1, dfs_loop_move_update_location
	
dfs_loop_move_recursive_call:
	# Load array base address
	move	$t0, $s4
	addu	$t0, $t0, $s5
	sw	$s6, 0($t0)
	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s4
	move	$a3, $s5
	jal	dfs
dfs_loop_move_update_location:
	# Move player back on a dead end
	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s0
	move	$a3, $s1
	jal	update_player_position
dfs_loop_move_return:
	lw	$ra, 16($sp)
	lw	$s3, 12($sp)
	lw	$a2, 8($sp)
	lw	$a1, 4($sp)
	lw	$a0, 0($sp)
	addiu	$sp, $sp, 20
	jr	$ra
	
	
# Checks if the address has already been visited
# Parameters:
#	$a0: visited
#	$a1: address
# Returns:
#	$v0: bool; visited
already_visited:
	li	$v0, 0
	move	$v1, $a0
	lw	$t0, ($a0)
	beq	$t0, 0, already_visited_return
	beq	$t0, $a1, already_visited_found
	addi	$a0, $a0, 4
	j	already_visited
already_visited_found:
	li	$v0, 1
already_visited_return:	
	jr	$ra

# Retrieves first empty space after the start of the visited items
# Parameters:
#	$a0: visited
# Returns:
#	$v0: free address
first_empty_in_visited:
	lw	$t0, ($a0)
	beq	$t0, 0, found
	addiu	$a0, $a0, 1
	j	first_empty_in_visited
found:
	move	$v0, $a0
	jr	$ra
	
# Sleep t7 milliseconds
# Parameters:
#	t7: milliseconds to sleep
sleep:
	subi	$sp, $sp, 8
	sw	$ra, 4($sp)
	sw	$a0, 0($sp)
	move	$a0, $t7
	li	$v0, 32
	syscall
	lw	$ra, 4($sp)
	lw	$a0, 0($sp)
	addi	$sp, $sp, 1	
	jr	$ra

	
	
	
