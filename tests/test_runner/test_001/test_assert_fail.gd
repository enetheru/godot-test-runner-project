@tool
extends TR_Base

# This test should fail.

const DESCRIPTION: String = "This test fails an assertion."

func _run_test() -> RetCode:
	assert(false, "run command must fail to return")
	return RetCode.TEST_OK
