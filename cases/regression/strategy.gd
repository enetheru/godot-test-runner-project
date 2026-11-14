@tool
extends TR_StrategyScript

## The schedule accepts a planted failure, ignores a skip, and keeps a case file's status.


class ReturnFail extends TR_Case:
	func _run_test() -> int:
		session.check( true, "body" )
		return TR_CaseSession.TEST_FAILED


class Gate extends TR_Hook:
	func _pre() -> Error:
		return FAILED


	func _post() -> Error:
		return OK


class PreFail extends TR_Case:
	func _configure() -> void:
		session.hooks.append( Gate.new() )


	func _run_test() -> int:
		session.check( false, "body ran" )
		return TR_CaseSession.TEST_OK


func _title() -> String:
	return "Strategy"


func _description() -> String:
	return "The schedule accepts a planted failure, ignores a skip, and keeps a case file's status."


func _children() -> Array:
	return [
		{
			"name": "return",
			"case": ReturnFail.new(),
			"expect": "fail",
		},
		{
			"name": "pre",
			"case": PreFail.new(),
			"expect": "fail",
			"hook_plant": true,
		},
		{
			"skip": "skipped — no expected status",
		},
		{
			"name": "values.gd",
			"path": "res://cases/regression/values.gd",
			"expect": "pass",
		},
	]
