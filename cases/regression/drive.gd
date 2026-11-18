extends RefCounted

## Runs a planted body on its own session and returns that session's status.
## The caller stays a passing case.


static func run( outer:TR_CaseSession, body:TR_Case ) -> int:
	var inner := TR_CaseSession.new()
	inner.host = outer.host
	inner.case_path = outer.case_path
	inner.load_listed_hooks = false
	if outer.tree != null:
		inner.attach_tree( outer.tree )
	else:
		inner.attach_loop()

	await inner.run_await( body )
	return inner.status
