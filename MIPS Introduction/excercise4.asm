	.data
jtable:	.word CASE0, CASE1, CASE2
 	.text

main:
	# int i
	li	$t1, 0
	# int a
	li 	$t5, 0
	# Branch to DEFAULT to prevent indexOutOfRange
	bgt	$t1, 2, DEFAULT
	# Load jump table address
	la	$t0, jtable
	# Multiply i with 4 for the address
	sll	$t1, $t1, 2
	# 
	add	$t2, $t0, $t1
	lw	$t4, ($t2)
	jr 	$t4

CASE0:
	# a = 9
	li	$t5, 9
	j exit

CASE1:
	# a = 6
	li	$t5, 6

CASE2:
	# a = 8
	li	$t5, 8
	j exit

DEFAULT:
	# a = 7
	li	$t5, 7
	j exit

exit:
	# Print a
	la	$a0, ($t5)
	li 	$v0, 1
	syscall
	# Terminate program
	li	$v0, 10
	syscall
