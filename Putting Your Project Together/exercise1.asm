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
fileName: 	.asciiz "C:/Users/robbe/Documents/University/Bachelor 1/CSA/Mars/Projects/Putting Your Project Together/input.txt"
fileContent:	.space 2048
# Characters
newLine: 	.asciiz "\n"
# Coordinates
playerRow:	.word 0
playerColumn:	.word 0

	.text
main:
	la	$a0, fileName
	jal	load_maze
	#li	$v0, 32
	#li	$a0, 2000
	#syscall
	#lw	$a0, playerRow
	#lw	$a1, playerColumn
	#addiu	$a2, 
	#jal	update_player_position
	j exit

# Updates player position
# Parameters:
#	a0: current player row
#	a1: current player column
#	a2: new player row
#	a3: new player column
update_player_position:
	addi	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$a3, 12($sp)
	sw	$a2, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
	# Current player position address
	jal 	coords_to_address
	lw	$t1, black
	sw	$v0, ($t0)
	# New player position address
	move	$a0, $a2
	move	$a1, $a3
	jal 	coords_to_address
	lw	$t1, yellow
	sw	$v0, ($t0)
	# Restore values
	lw	$ra, 16($sp)
	lw	$a3, 12($sp)
	lw	$a2, 8($sp)
	lw	$a1, 4($sp)
	lw	$a0, 0($sp)
	addi	$sp, $sp, 20

# Loads a maze based on the contents of a file
# Parameters:
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
	
	# Save player coordinates
	bne	$t1, 115, load_bitmap_loop_color_pixel
	lw	$a2, playerRow
	lw	$a1, playerColumn
load_bitmap_loop_color_pixel:
	# Save values
	addi	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
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
	# Default
	la	$t0, purple
	#jr	$ra
map_char_to_color_return:
	lw	$t1, ($t0)
	move	$v0, $t1
	jr	$ra

# Map row and column to an address
# Parameters:
#	a0: column
#	a1: row
# Returns:
#	v0: address
coords_to_address:
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

# Terminates program
exit:
	li	$v0, 10
	syscall

