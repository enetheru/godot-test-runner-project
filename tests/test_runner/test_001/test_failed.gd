@tool
extends TR_Base

# This test should fail.
func _run_test() -> RetCode:
	return RetCode.TEST_FAILED
