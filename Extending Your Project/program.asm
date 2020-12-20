	.data
# Dimensions
width: 		.word 32
height: 	.word 32
# Colors
red:		.word 0x00ff0000
yellow:		.word 0x00ffff00
green:		.word 0x0000ff00
blue:		.word 0x000000ff
black:		.word 0x00000000
white:		.word 0x00ffffff
purple:		.word 0x006a0dad
# File
fileName: 	.asciiz "C:/Users/robbe/Documents/University/Bachelor 1/CSA/Mars/Projects/Extending Your Project/input.txt"
fileContent:	.space 2048
# Characters
newLine: 	.asciiz "\n"
# Coordinates
playerRow:	.word 0
playerColumn:	.word 0
# Messages
victory:	.asciiz "Congratulations! You won!"

	.text
main:
	la	$a0, fileName
	jal	load_maze
	lw	$t0, width
	lw	$t1, height
	multu	$t0, $t1
	mflo	$t0
	sll	$t0, $t0, 2
	add	$t1, $gp, $t
	
	j exit
	#j gameloop

# Checks for input every 60 ms
gameloop:
	# Sleep for 2 seconds
	li	$t7, 60
	jal	sleep
	# Check for input
	la	$t1, 0xffff0000
	lw	$t2, ($t1)
	beq	$t2, 1, input_available
	j gameloop

# Function called when input is available
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
	# Add directions to current position
	add	$a2, $a0, $s0
	add	$a3, $a1, $s1
	# Move player
	jal update_player_position
	j gameloop
pressed_z:
	li	$s0, -1
	li	$s1, 0
	j handled_input
pressed_s:
	li	$s0, 1
	li	$s1, 0
	j handled_input
pressed_q:
	li	$s0, 0
	li	$s1, -1
	j handled_input
pressed_d:
	li	$s0, 0
	li	$s1, 1
	j handled_input
pressed_x:
	j exit


# Loads a maze based on the contents of a file
# Input:
# 	a0: asciiz; fileName
# Stack:
# 	$ra
#	$t0
#	$a0
load_maze:
	# Save return address and argument to the stack
	addi	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$a0, 0($sp)
	
	# Read the file
	# Filename is still in a0
	li	$v0, 13
    	li	$a1, 0 # 0 to read
    	syscall
    	# Save file descriptor
    	move	$s0, $v0
	# Load file contents
	li	$v0,  14
	move	$a0, $s0
	la 	$a1, fileContent
	la 	$a2, 2048
	syscall
	
	# Loads bitmap
	la 	$a0, fileContent
	jal	load_bitmap
	
	# Close file
    	li 	$v0,  16
    	move 	$a0, $s0
    	syscall
    	
    	# Load initial values from Stack
    	lw	$ra, 8($sp)
    	lw	$s0, 4($sp)
    	lw	$a0, 0($sp)
    	addi	$sp, $sp, 12
    	
    	jr	$ra

# Loads bitmap in memory and stores the width and height of the maze from a string in memory
# Parameters:
#	a0: string; file contents
# Stack:
#	$ra
#	$a0
load_bitmap:
	# Save to Stack
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$a0, 0($sp)
	# counter = 0
	li	$a1, 0
	# y = 2
	li	$a2, 1
	# get_dimensions_recursive(filecontent, counter, y)
	jal load_bitmap_loop
	# Store width and height in memory
	sw	$v0, width
	sw	$v1, height
	# Save player column index
	lw	$t0, playerColumn
	div	$t0, $v0
	mfhi	$t1
	sw	$t1, playerColumn
	# Subtract 1 form playerRow to start counting from 0
	lw	$t0, playerRow
	addiu	$t0, $t0, -1
	sw	$t0, playerRow
	# Load inital values
	lw	$ra, 4($sp)
	lw	$a0, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra

# Iterates over file contents and loads pixels in memory
# Parameters:
#	a0: *string; file contents
#	a1: int; index
#	a2: int; y count
# Returns:
#	v0: int; width
#	v1: int; height
load_bitmap_loop:
	# Load string[index]
	lb	$t1, ($a0)
	# Incremeent string pointer
	addi	$a0, $a0, 1
	
	# Switch character
	beq	$t1, 10, load_bitmap_loop_newline
	beq	$t1, 0, load_bitmap_loop_file_end
	
	# Save values
	addi	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
	
	# Save player coordinates
	bne	$t1, 115, load_bitmap_loop_color_pixel
	sw	$a2, playerRow
	sw	$a1, playerColumn
load_bitmap_loop_color_pixel:
	# Set pixel to right color
	move	$a0, $t1
	jal 	map_char_to_color
	move 	$t2, $v0
	# Restore values
	lw	$ra, 8($sp)
	lw	$a1, 4($sp)
	lw	$a0, 0($sp)
	addi	$sp, $sp, 12
	# Multiply i with 4 to get the address
	sll 	$t3, $a1, 2
	# Add the relative address to gp address
	add 	$t4, $gp, $t3
	# Write the color to the bitmap memory
	sw 	$t2, ($t4)
	# Increment counter
	addiu	$a1, $a1, 1
	
	j load_bitmap_loop
load_bitmap_loop_newline:
	addi	$t1, $a0, 1
	lb	$t2, ($t1)
	beq	$t2, 0, load_bitmap_loop_file_end
	# Increment y value
	addiu	$a2, $a2, 1
	j load_bitmap_loop
load_bitmap_loop_file_end:
	li	$v0, 0
	li	$v1, 0
	# Return if file is empty
	beq	$a1, 0, load_bitmap_loop_return
	# Set v1 to y
	move	$v1, $a2
	divu	$a1, $a2
	mflo	$v0
load_bitmap_loop_return:
	jr	$ra

# Returns the hexadecimal value of the color that's represented by the character
# Parameter:
#	a0: int; byte code
# Returns:
#	v0: int; color code
map_char_to_color:
	# p => black
	la	$t0, black
	beq	$a0, 112, map_char_to_color_return
	# w => blue
	la	$t0, blue
	beq	$a0, 119, map_char_to_color_return
	# s => yellow
	la	$t0, yellow
	beq	$a0, 115, map_char_to_color_return
	# u => green
	la	$t0, green
	beq	$a0, 117, map_char_to_color_return
	# e => red
	la	$t0, red
	beq	$a0, 114, map_char_to_color_return
	# c => white
	la	$t0, white
	beq	$a0, 99, map_char_to_color_return
	# Default is purple to make it obvious
	la	$t0, purple
	#jr	$ra
map_char_to_color_return:
	lw	$v0, ($t0)
	jr	$ra
	
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
	# Save initial values
	addi	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s1, 20($sp)
	sw	$s0, 16($sp)
	sw	$a3, 12($sp)
	sw	$a2, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
	# Check min size
	move	$v0, $a0
	move	$v1, $a1
	blt	$a0, 0, update_player_restore
	blt	$a1, 0, update_player_restore
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
	bge	$a0, $t1, update_player_restore
	bge	$a1, $t0, update_player_restore
	lw	$t3, ($s1)
	lw	$t4, blue
	beq	$t3, $t4, update_player_restore # new spot is wall
	lw	$t5, green
	beq	$t3, $t5, player_won # new spot is destination
	# Move is possible so load the new coordinates
	move	$v0, $a0
	move	$v1, $a1
	# Color pixels if position is valid
	lw	$t1, black
	sw	$t1, ($s0)
	lw	$t1, yellow
	sw	$t1, ($s1)
	# Update player coordinates
	sw	$v0, playerRow
	sw	$v1, playerColumn
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

# Prints a victory message and terminates the program
player_won:
	la	$a0, victory
	jal	print_string
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


# Prints a string
# Parameters:
#	a0: string; value to print
print_string:
	li 	$v0,  4
	syscall
	jr	$ra

# Prints an integer
# Parameters:
#	a0: word; integer to print
print_int:
	li 	$v0,  1
	syscall
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


# Terminates program
exit:
	li	$v0, 10
	syscall
