@tool
extends TR_Case

## The body passes. Post returns an error.
## The host reports fail.

const DESCRIPTION: String = "The body passes. Post returns an error. The host reports fail."


class Gate extends TR_Hook:
	func _pre() -> Error:
		return OK


	func _post() -> Error:
		return FAILED


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _configure() -> void:
	session.hooks.append( Gate.new() )


func _run_test() -> int:
	return TR_CaseSession.TEST_OK
