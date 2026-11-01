# This script is modified automatically to work in play mode.
extends PlayBase
# This test should fail.
func _run_test() -> RetCode:
	assert(false, "run command must fail to return")
	return RetCode.TEST_OK
