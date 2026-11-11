@tool
extends TR_Case

## Pre returns an error. The host reports fail and skips the body.

const DESCRIPTION: String = "Pre returns an error. The host reports fail and skips the body."


class Gate extends TR_Hook:
	func pre() -> Error:
		return FAILED


	func post() -> Error:
		return OK


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _configure() -> void:
	session.hooks = Gate.new()


func _run_test() -> int:
	session.check( false, "body ran" )
	return session.runcode
