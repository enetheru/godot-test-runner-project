@tool
extends TR_Base

## PhysicsServer2D is registered on the engine.

const DESCRIPTION: String = "PhysicsServer2D is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("PhysicsServer2D"), "PhysicsServer2D exists")
	return runcode as RetCode
