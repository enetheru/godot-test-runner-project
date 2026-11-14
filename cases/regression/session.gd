@tool
extends TR_Case

## Configure can replace the budget. A planted fault reports its own status,
## and the body of a failed setup or pre does not run.

const Drive = preload( "drive.gd" )

const BUDGET_S: float = 3.0


class Plant extends TR_Case:
	var body_ran: bool = false


class SetupFault extends Plant:
	func _setup() -> Error:
		return FAILED

	func _run_test() -> int:
		body_ran = true
		return TR_CaseSession.TEST_OK


class CleanupFault extends Plant:
	func _run_test() -> int:
		return TR_CaseSession.TEST_OK

	func _cleanup() -> Error:
		return FAILED


class PreGate extends TR_Hook:
	func _pre() -> Error:
		return FAILED

	func _post() -> Error:
		return OK


class PreFault extends Plant:
	func _configure() -> void:
		session.hooks.append( PreGate.new() )

	func _run_test() -> int:
		body_ran = true
		return TR_CaseSession.TEST_OK


class PostGate extends TR_Hook:
	func _pre() -> Error:
		return OK

	func _post() -> Error:
		return FAILED


class PostFault extends Plant:
	func _configure() -> void:
		session.hooks.append( PostGate.new() )

	func _run_test() -> int:
		return TR_CaseSession.TEST_OK


class ReturnFault extends Plant:
	func _run_test() -> int:
		session.check( true, "body" )
		return TR_CaseSession.TEST_FAILED


class CheckFault extends Plant:
	func _run_test() -> int:
		session.check( 1 == 2, "one equals two" )
		return TR_CaseSession.TEST_OK


func _description() -> String:
	return "Configure can replace the budget. A planted fault reports its own status, and the body of a failed setup or pre does not run."


func _configure() -> void:
	session.check( session.budget_s == 3.0, "budget from the constant" )
	session.budget_s = 4.0


func _run_test() -> int:
	session.check( session.budget_s == 4.0, "budget replaced" )
	await _watch( SetupFault.new(), "setup failed", true )
	await _watch( CleanupFault.new(), "cleanup failed", false )
	await _watch( PreFault.new(), "fail", true )
	await _watch( PostFault.new(), "fail", false )
	await _watch( ReturnFault.new(), "fail", false )
	await _watch( CheckFault.new(), "fail", false )
	return session.runcode


func _watch( plant: Plant, expect: String, skip_body: bool ) -> void:
	var got: String = await Drive.run( session, plant )
	session.check( got == expect, expect )
	if skip_body:
		session.check( not plant.body_ran, expect + " skipped the body" )
