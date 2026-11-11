@tool
extends TR_Case

## The editor host runs this. Play and the script host refuse it.

const DESCRIPTION: String = "The editor host runs this. Play and the script host refuse it."

const EDITOR_ONLY: bool = true


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _run_test() -> int:
	session.check( session.host == TR_CaseSession.Host.EDITOR, "host" )
	session.check( session.hint, "hint" )
	return session.runcode
