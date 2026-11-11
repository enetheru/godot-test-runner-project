@tool
extends TR_Base

## Passing checks. Return [member runcode] so a failed check stays failed.

func _run_test() -> RetCode:
	TEST_TRUE(1 + 1 == 2, "arithmetic")
	TEST_FALSE(1 == 2, "not equal")
	TEST_EQ("ok", "ok", "same string")
	TEST_APPROX(0.1 + 0.2, 0.3, "float sum")
	TEST_OP(3, OP_GREATER, 1, "three is greater")
	return runcode as RetCode
