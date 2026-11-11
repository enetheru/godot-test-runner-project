@tool
extends TR_Base

## PhysicsServer3D is registered on the engine.

const DESCRIPTION: String = "PhysicsServer3D is registered on the engine."

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("PhysicsServer3D"), "PhysicsServer3D exists")
	return runcode as RetCode
