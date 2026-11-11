@tool
extends TR_Base

## AudioServer is registered on the engine.

func _run_test() -> RetCode:
	TEST_TRUE(Engine.has_singleton("AudioServer"), "AudioServer exists")
	return runcode as RetCode
