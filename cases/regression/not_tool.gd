extends TR_Case

## Empty body. This script has no [code]@tool[/code] annotation, so the editor host cannot construct it.


func _title() -> String:
	return "Not a tool"


func _description() -> String:
	return "Empty body. This script has no @tool annotation, so the editor host cannot construct it."


func _run_test() -> int:
	return TR_CaseSession.TEST_OK
