	.data
pi: .float 3.141592653589

	.text
main:
	# Read float input
	li 	$v0, 6
	syscall
	# Square the radius
	mul.s	$f0, $f0, $f0
	# Load pi
	l.s	$f1, pi
	# Multiply the squared radius with pi
	mul.s	$f12, $f0, $f1
	# Print radius
	li 	$v0, 2
	syscall
	# Terminate program
	li 	$v0, 10
	syscall