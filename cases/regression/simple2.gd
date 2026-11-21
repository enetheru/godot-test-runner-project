@tool
extends TR_Case

## Extremely Simple Empty Case to show the shape of the test runner.


func _title() -> String:
	return "Simple"


func _description() -> String:
	return "Empty Simple Case"


func _run_test() -> int:
	return TR_CaseSession.TEST_OK
