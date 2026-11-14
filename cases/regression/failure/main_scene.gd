@tool
extends TR_Case

## The editor dock and the script host refuse this before the body.
## A play of the project main scene runs the check.

const NEEDS_MAIN_SCENE: bool = true


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _description() -> String:
	return "The editor dock and the script host refuse this before the body. A play of the project main scene runs the check."


func _run_test() -> int:
	session.check( session.main_scene_started, "main scene" )
	return session.runcode
