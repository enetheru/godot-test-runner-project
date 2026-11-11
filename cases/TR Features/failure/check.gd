@tool
extends TR_Case

## A false check. Returning pass does not clear it.
## The host reports fail, and the label is an output line.

const DESCRIPTION: String = "A false check. Returning pass does not clear it. The host reports fail, and the label is an output line."


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _run_test() -> int:
	session.check( 1 + 1 == 2, "arithmetic" )
	session.check( 1 == 2, "one equals two" )
	session.check( true, "later check" )
	return TR_CaseSession.TEST_OK
