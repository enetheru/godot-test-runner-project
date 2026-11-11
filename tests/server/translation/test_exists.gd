@tool
extends TR_Base

## TranslationServer is registered on the engine.

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("TranslationServer"), "TranslationServer exists")
	return runcode as RetCode
