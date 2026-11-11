@tool
extends TR_Base

## NavigationServer3D is registered on the engine.

const DESCRIPTION: String = "NavigationServer3D is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("NavigationServer3D"), "NavigationServer3D exists")
	return runcode as RetCode
