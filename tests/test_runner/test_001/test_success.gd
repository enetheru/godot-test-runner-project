@tool
extends TR_Base

# This test should succeed

const DESCRIPTION: String = "This test should succeed."

func _run_test() -> RetCode:
	return RetCode.TEST_OK
