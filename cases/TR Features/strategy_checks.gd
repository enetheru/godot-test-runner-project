@tool
extends TR_StrategyScript

## One case. The product is inside [method Checks._run_test].
## Each [code]TEST_*[/code] call passes.


## The single child. Setup and cleanup run once around these calls.
class Checks extends TR_Case:
	func _run_test() -> int:
		var eq:int = session.TEST_EQ_RET( 1, 1, "eq" )
		session.TEST_EQ( "ok", "ok", "eq" )
		var approx:int = session.TEST_APPROX_RET( 0.3, 0.1 + 0.2, "approx" )
		session.TEST_APPROX( 0.3, 0.1 + 0.2, "approx" )
		var truth:int = session.TEST_TRUE_RET( true, "true" )
		session.TEST_TRUE( 1, "true" )
		var falsehood:int = session.TEST_FALSE_RET( false, "false" )
		session.TEST_FALSE( 0, "false" )
		var less:int = session.TEST_OP_RET( 1, OP_LESS, 2, "less" )
		session.TEST_OP( 1, OP_LESS, 2, "less" )
		if eq != TR_CaseSession.TEST_OK \
		or approx != TR_CaseSession.TEST_OK \
		or truth != TR_CaseSession.TEST_OK \
		or falsehood != TR_CaseSession.TEST_OK \
		or less != TR_CaseSession.TEST_OK:
			return session.runcode

		return session.runcode


func _title() -> String:
	return "Strategy checks"


func _description() -> String:
	return "One case. _run_test calls every TEST_* function and each one passes."


func _children() -> Array:
	return [ {
		"name": "checks",
		"expect": "pass",
		"case": Checks.new(),
	} ]
