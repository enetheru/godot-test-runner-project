@tool
extends TestBase

## PhysicsServer2D is registered on the engine.

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("PhysicsServer2D"), "PhysicsServer2D exists")
	return runcode as RetCode
