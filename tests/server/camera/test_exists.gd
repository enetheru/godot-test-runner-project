@tool
extends TR_Base

## CameraServer is registered on the engine.

const DESCRIPTION: String = "CameraServer is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("CameraServer"), "CameraServer exists")
	return runcode as RetCode
