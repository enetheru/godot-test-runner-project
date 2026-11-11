@tool
extends TR_Case

## Setup returns an error and acquires nothing.
## The host reports setup failed. The body does not run.

const DESCRIPTION: String = "Setup returns an error and acquires nothing. The host reports setup failed. The body does not run."


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _setup() -> Error:
	return FAILED


func _run_test() -> int:
	session.check( false, "body ran" )
	return session.runcode
