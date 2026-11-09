@tool
extends Case

## Configure replaces the budget and installs hooks.
##
## Pre runs before the body. Post appends an output line. [code]BUDGET_S[/code]
## is the value configure replaces.


const BUDGET_S := 9.0


class Probe extends RunHooks:
	var saw_pre: bool = false
	var sink: CaseSession


	func pre() -> Error:
		saw_pre = true
		return OK


	func post() -> Error:
		sink._note( "post" )
		# Drop the session edge. session.hooks is the remaining reference.
		sink = null
		return OK


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _configure() -> void:
	session.check( session.budget_s == 9.0, "constant" )
	session.budget_s = 2.5
	var probe := Probe.new()
	probe.sink = session
	session.hooks = probe


func _run_test() -> int:
	session.check( session.budget_s == 2.5, "budget" )
	var installed: Variant = session.hooks
	session.check( installed is Probe, "hooks" )
	if installed is Probe:
		var probe: Probe = installed
		session.check( probe.saw_pre, "pre" )
	return session.runcode
