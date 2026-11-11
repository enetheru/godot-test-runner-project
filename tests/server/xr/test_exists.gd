@tool
extends TR_Base

## XRServer is registered on the engine.

const DESCRIPTION: String = "XRServer is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("XRServer"), "XRServer exists")
	return runcode as RetCode
