@tool
extends TestBase

## RenderingServer is registered on the engine.

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("RenderingServer"), "RenderingServer exists")
	return runcode as RetCode
