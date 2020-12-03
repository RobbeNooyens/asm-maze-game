	.data
width: .word 32
height: .word 32
red: .word 0x00ff0000

	.text

main:
	# Load width, height and red color
	lw 	$s0, width
	lw 	$s1, height
	lw 	$s2, red
	li 	$t0, 0
	# Store total amount of pixels in s3 register
	mult	$s0, $s1
	mflo	$s3
	j fill
	
	
fill:
	# Exit loop if i >= amount of pixels
	bge 	$t0, $s3, exit
	# Multiply i with 4 to get the address
	sll 	$t2, $t0, 2
	# Add the relative address to gp address
	add 	$t3, $gp, $t2
	# Write the color red to the bitmap memory
	sw 	$s2, ($t3)
	# i++
	addi 	$t0, $t0, 1
	j fill

exit:
	# Terminate the program
	li 	$v0, 10
	syscall
