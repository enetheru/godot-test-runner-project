@tool
extends TR_Case

## Tracy on a scene tree. The script host refuses this before the body.
##
## [code]HOOKS[/code] names the capture script. The session loads it
## without this case assigning an instance. Pre fails when the tools
## are missing, so the body only runs once the hook has settled.

const DESCRIPTION: String = "Tracy on a scene tree. The script host refuses this before the body. HOOKS names the capture script. The session loads it. The body checks that the capture hook is installed."

const NEEDS_TREE := true

const HOOKS: PackedStringArray = [ "res://addons/enetheru.test-runner/runner/hooks/TracyCapture.gd" ]

const TracyCapture = preload( "uid://c38qii7m273x0" )


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _run_test() -> int:
	var found: bool = false
	for hook: TR_Hook in session.hooks:
		if hook.get_script() == TracyCapture:
			found = true
	session.check( found, "tracy" )
	return session.runcode
