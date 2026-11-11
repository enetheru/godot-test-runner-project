@tool
extends TR_Base

## AccessibilityServer is registered on the engine.

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("AccessibilityServer"), "AccessibilityServer exists")
	return runcode as RetCode
