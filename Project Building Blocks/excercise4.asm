	.data
fileName: 	.asciiz "C:/Users/robbe/Documents/University/Bachelor 1/CSA/Mars/Projects/Project Building Blocks/file.txt"
fileContent:	.space	1024

	.text
main:
	# Read the file
	li	$v0, 13
    	la	$a0, fileName
    	li	$a1, 0 # 0 to read
    	syscall
    	# Save file descriptor
    	move	$s0, $v0
	# Load file contents
	li	$v0,  14
	move	 $a0, $s0
	la 	$a1, fileContent
	la 	$a2, 1024
	syscall
	# Print contents
	li 	$v0,  4
	la 	$a0, fileContent
	syscall
	# Close file
    	li 	$v0,  16
    	move 	$a0, $s0
    	syscall
    	j exit

exit:
	# Terminate program
	li	$v0, 10
	syscall
