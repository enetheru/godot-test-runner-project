@tool
extends TR_Case

## Passing checks. No tree.

const DESCRIPTION: String = "Passing checks. No tree."


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _run_test() -> int:
	session.check( true, "true" )
	session.check( 1 + 1 == 2, "arithmetic" )
	session.check( "ok" == "ok", "same string" )
	session.check( is_equal_approx( 0.1 + 0.2, 0.3 ), "float sum" )
	session.check( 3 > 1, "three is greater" )
	return session.runcode
