	.data
# Dimensions
width: 		.word 32
height: 	.word 32
# Colors
red:		.word 0x00ff0000
yellow:		.word 0xffff00
# File
fileName: 	.asciiz "C:/Users/robbe/Documents/University/Bachelor 1/CSA/Mars/Projects/Project Building Blocks/file.txt"
fileContent:	.space 2048

	.text
main:
	la	$a0, fileName
	jal	load_maze


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
	
	# Print contents
	la 	$a0, fileContent
	jal print_string
	
	# Close file
    	li 	$v0,  16
    	move 	$a0, $s0
    	syscall

# Stores the width and height of the maze from a string in memory
# Parameters:
#	a0: string; file contents
# Stack:
#	$ra
#	$a0
get_dimensions:
	# Save to Stack
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$a0, 0($sp)
	# counter = 0
	li	$a1, 0
	# y = 2
	li	$a2, 1
	# get_dimensions_recursive(filecontent, counter, y)
	jal get_dimensions_recursive
	# Store width and height in memory
	sw	$v0, width
	sw	$v1, height
	# Load inital values
	lw	$ra, 4($sp)
	lw	$a0, 0($sp)
	addi	$sp, $sp, 8

# Iterate dimensions
# Parameters:
#	a0: string; file contents
#	a1: int; index
#	a2: int; y count
# Returns:
#	v0: int; width
#	v1: int; height
get_dimensions_recursive:
	# Load string[index]
	lb	$t1, ($a0)
	# Incremeent string pointer
	addi	$a0, $a0, 1
	beq	$t1, 10, get_dimensions_recursive_newline
	beq	$t1, 0, get_dimensions_recursive_file_end
	# Increment counter
	addiu	$a1, 1
	j get_dimensions_recursive
get_dimensions_recursive_newline:
	# Increment y value
	addiu	$a2, $a2, 1
	j get_dimensions_recursive
get_dimensions_recursive_file_end:
	li	$v0, 0
	li	$v1, 0
	# Return if file is empty
	beq	$a1, 0, get_dimensions_recursive_return
	# Set v1 to y
	move	$v1, $a2
	divu	$a1, $a2
	mflo	$v0
get_dimensions_recursive_return:
	jr	$ra
	
	
	
	
	
	

# Iterates over the filecontents to set the bitmap to the right color
# Parametes:
#	a0: string; filecontents
#	a1: int; x
#	a2: int; y
# Stack:
#	$ra
#	$a2
#	$a1
#	$a0
iterate_file:
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$a2, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)

# Maps an x and y coordinate to a memory address
# Parameters:
#	a0: int; x
#	a1: int; y
# Stack:
#	$ra
#	$a1
#	$a0
coordinates_to_address:
	addi	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$a1, 4($sp)
	sw	$a0, 0($sp)
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
	
	

