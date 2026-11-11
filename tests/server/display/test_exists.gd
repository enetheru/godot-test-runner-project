@tool
extends TR_Base

## DisplayServer is registered on the engine.

const DESCRIPTION: String = "DisplayServer is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("DisplayServer"), "DisplayServer exists")
	return runcode as RetCode
