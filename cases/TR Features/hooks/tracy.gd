@tool
extends TR_Case

## Tracy on a scene tree. The script host refuses this before the body.
##
## [method _configure] appends the capture hook. Pre fails when the tools
## are missing, so the body only runs once the hook has settled.

const DESCRIPTION: String = "Tracy on a scene tree. The script host refuses this before the body. Configure appends the capture hook. The body checks that the capture hook is installed."

const NEEDS_TREE := true

const TracyCapture = preload( "uid://c38qii7m273x0" )


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _configure() -> void:
	session.hooks.append( TracyCapture.new() )


func _run_test() -> int:
	var found: bool = false
	for hook: TR_Hook in session.hooks:
		if hook.get_script() == TracyCapture:
			found = true
	session.check( found, "tracy" )
	return session.runcode
