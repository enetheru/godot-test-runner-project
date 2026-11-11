@tool
extends TR_Base

## RenderingServer is registered on the engine.

const DESCRIPTION: String = "RenderingServer is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("RenderingServer"), "RenderingServer exists")
	return runcode as RetCode
