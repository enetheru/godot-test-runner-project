@tool
extends TR_Case

## Every comparison helper agrees, and a true check leaves the code at pass.


func _description() -> String:
	return "Every comparison helper agrees, and a true check leaves the code at pass."


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
	session.check( eq == TR_CaseSession.TEST_OK, "eq" )
	session.check( approx == TR_CaseSession.TEST_OK, "approx" )
	session.check( truth == TR_CaseSession.TEST_OK, "true" )
	session.check( falsehood == TR_CaseSession.TEST_OK, "false" )
	session.check( less == TR_CaseSession.TEST_OK, "less" )
	return session.runcode
