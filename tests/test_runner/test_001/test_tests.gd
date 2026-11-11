@tool
extends TR_Base

# This test should Succeed

const DESCRIPTION: String = "Passing checks for true, equal, and comparison."

func _run_test() -> int:
	TEST_TRUE( true )

	TEST_EQ( 1, 1, "Testing EQUAL")

	TEST_OP( 1, OP_EQUAL, 1, "Testing OP_EQUAL = true")
	TEST_OP( 1, OP_NOT_EQUAL, 0, "Testing OP_NOT_EQUAL = true")
	TEST_OP( 1, OP_GREATER_EQUAL, 0, "Testing OP_GREATER_EQUAL = true")
	TEST_OP( 1, OP_GREATER_EQUAL, 1, "Testing OP_GREATER_EQUAL = true")
	TEST_OP( 1, OP_GREATER, 0, "Testing OP_GREATER = true")
	TEST_OP( 0, OP_LESS_EQUAL, 1, "Testing OP_LESS_EQUAL = true")
	TEST_OP( 1, OP_LESS_EQUAL, 1, "Testing OP_LESS_EQUAL = true")
	TEST_OP( 0, OP_LESS, 1, "Testing OP_LESS = true")

	TEST_APPROX(1.1,1.1,"Testing APPROX")

	return runcode
