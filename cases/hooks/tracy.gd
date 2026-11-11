@tool
extends TR_Case

## Tracy on a scene tree. The script host refuses this before the body.
##
## Hooks stay empty. The session assigns TracyCapture when this run asks
## for a capture and the tools are configured. A skipped capture leaves
## hooks empty.

const DESCRIPTION: String = "Tracy on a scene tree. The script host refuses this before the body. Hooks stay empty. The session assigns TracyCapture when this run asks for a capture and the tools are configured. A skipped capture leaves hooks empty."

const NEEDS_TREE := true

const TracyCapture = preload( "uid://c38qii7m273x0" )
const TR_Opts = preload( "uid://c3rwpcm55iy6r" )


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _run_test() -> int:
	var installed:Object = session.hooks
	if _expects_capture():
		var same:bool = installed != null and installed.get_script() == TracyCapture
		session.check( same, "tracy" )
	else:
		session.check( installed == null, "skipped" )
	return session.runcode


func _expects_capture() -> bool:
	if session.capture_request == 0 or session.tree == null:
		return false
	if not TracyCapture.is_configured():
		return false
	if session.capture_request == 1:
		return true
	var opts:TR_Opts = TR_Opts.shared() as TR_Opts
	return opts != null and opts.tracy and Engine.has_singleton( &"Profiler" )
