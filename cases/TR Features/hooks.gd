@tool
extends TR_Case

## Pre runs before the body. Post appends an output line.

const DESCRIPTION: String = "Pre runs before the body. Post appends an output line."


class Probe extends TR_Hook:
	## True after pre returns.
	var saw_pre: bool = false

	## Session for the post line. Cleared in post.
	var sink: TR_CaseSession


	func _pre() -> Error:
		saw_pre = true
		return OK


	func _post() -> Error:
		sink._note( "post" )
		# The session still holds this hook.
		sink = null
		return OK


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _configure() -> void:
	var probe := Probe.new()
	probe.sink = session
	session.hooks.append( probe )


func _run_test() -> int:
	var installed: Probe = _probe()
	session.check( installed != null, "hooks" )
	if installed != null:
		session.check( installed.saw_pre, "pre" )

	return session.runcode


func _probe() -> Probe:
	for hook: TR_Hook in session.hooks:
		if hook is Probe:
			return hook as Probe
	return null
