@tool
extends TR_Base

# This test should fail.

const DESCRIPTION: String = "This test returns fail."

func _run_test() -> RetCode:
	return RetCode.TEST_FAILED
