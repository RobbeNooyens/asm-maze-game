	.data
# Dimensions
width: .word 32
height: .word 32
# Colors
red: .word 0x00ff0000
yellow: .word 0xffff00

	.text

main:
	# Load width, height and red color
	lw 	$s0, width
	lw 	$s1, height
	lw 	$s2, red
	lw	$s3, yellow
	li 	$t0, 0
	# Store total amount of pixels in s4 register
	mult	$s0, $s1
	mflo	$s4
	j fill_screen
	
	
fill_screen:
	# Exit loop if i >= amount of pixels
	bgt 	$t0, $s4, exit	
check_color:
	# Divide i by width
	div 	$t0, $s0
	# Change left and right side to yellow
	# Quotient is 0 or width-1
	mfhi	$t1
	beq	$t1, 0, select_yellow
	subi	$t2, $s0, 1
	beq	$t1, $t2, select_yellow
	# Change top and bottom line to yellow
	# Remainder is 0 or height-1
	mflo	$t1
	beq	$t1, 0, select_yellow
	subi	$t2, $s1, 1
	beq	$t1, $t2, select_yellow
select_red:
	move	$t3, $s2
	j fill_pixel
select_yellow:	
	move 	$t3, $s3
fill_pixel:	
	# Multiply i with 4 to get the address
	sll 	$t2, $t0, 2
	# Add the relative address to gp address
	add 	$t4, $gp, $t2
	# Write the color red to the bitmap memory
	sw 	$t3, ($t4)
	# i++
	addi 	$t0, $t0, 1
	j fill_screen

exit:
	# Terminate the program
	li 	$v0, 10
	syscall
