@tool
extends TestBase

## AccessibilityServer is registered on the engine.

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("AccessibilityServer"), "AccessibilityServer exists")
	return runcode as RetCode
