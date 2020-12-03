	.data
 space: .asciiz " "
 newline: .asciiz "\n"
	.text

main:
	li $v0, 5
	syscall
	move $t0, $v0
	li $t1, 0
	j loop

loop:
	addi 	$t1, $t1, 1
	bgt $t1, $t0, exit	# if ($t1 >= $t0) => exit
	li 	$t2, 1
	j printline

printline:
	bgt 	$t2, $t1, printed
	li	$v0, 1
	la	$a0, ($t2)
	syscall
	addi	$t2, $t2, 1
	li 	$v0, 4
	la	$a0, space
	syscall
	j printline

printed:
	li 	$v0, 4
	la	$a0, newline
	syscall
	j loop
	
exit:
	li	$v0, 10
	syscall
