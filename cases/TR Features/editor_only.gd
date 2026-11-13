@tool
extends TR_Case

## The editor host runs this. Play and the script host refuse it.

const EDITOR_ONLY: bool = true


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _description() -> String:
	return "The editor host runs this. Play and the script host refuse it."


func _run_test() -> int:
	session.check( session.host == TR_CaseSession.Host.EDITOR, "host" )
	session.check( session.hint, "hint" )
	return session.runcode
