@tool
extends TR_Base

## Never emitted. The max-runtime timer has to finish this run.
signal _stuck


# This test should time out.
func _run_test() -> RetCode:
	await _stuck
	return RetCode.TEST_OK
