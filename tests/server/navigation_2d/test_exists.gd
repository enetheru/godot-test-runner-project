@tool
extends TR_Base

## NavigationServer2D is registered on the engine.

const DESCRIPTION: String = "NavigationServer2D is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("NavigationServer2D"), "NavigationServer2D exists")
	return runcode as RetCode
