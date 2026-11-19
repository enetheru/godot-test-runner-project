@tool
extends TR_Case

## This case asks the launcher for its own executable.


const OWN_PROCESS:bool = true


func _description() -> String:
	return "This case asks the launcher for its own executable."


func _run_test() -> int:
	return session.runcode
