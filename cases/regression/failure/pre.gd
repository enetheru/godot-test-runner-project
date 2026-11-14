@tool
extends TR_Case

## Pre returns an error. The host reports fail and skips the body.

class Gate extends TR_Hook:
	func _pre() -> Error:
		return FAILED


	func _post() -> Error:
		return OK


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _description() -> String:
	return "Pre returns an error. The host reports fail and skips the body."


func _configure() -> void:
	session.hooks.append( Gate.new() )


func _run_test() -> int:
	session.check( false, "body ran" )
	return session.runcode
