@tool
extends TR_Case

## Configure replaces the budget and installs hooks.
##
## Pre runs before the body. Post appends an output line. [code]BUDGET_S[/code]
## is the value configure replaces.


const DESCRIPTION: String = "Configure replaces the budget and installs hooks. Pre runs before the body. Post appends an output line. BUDGET_S is the value configure replaces."

const BUDGET_S := 9.0


class Probe extends TR_Hook:
	var saw_pre: bool = false
	var sink: TR_CaseSession


	func _pre() -> Error:
		saw_pre = true
		return OK


	func _post() -> Error:
		sink._note( "post" )
		# Drop the session edge. The hooks array is the remaining reference.
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
	session.hooks.append( probe )


func _run_test() -> int:
	session.check( session.budget_s == 2.5, "budget" )
	var installed: Probe = null
	for hook: TR_Hook in session.hooks:
		if hook is Probe:
			installed = hook as Probe
	session.check( installed != null, "hooks" )
	if installed != null:
		session.check( installed.saw_pre, "pre" )
	return session.runcode
