@tool
extends TR_Case

## [code]BUDGET_S[/code] fills the budget. Configure replaces it.

const DESCRIPTION: String = "BUDGET_S fills the budget. Configure replaces it."

const BUDGET_S: float = 3.0


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _configure() -> void:
	session.check( session.budget_s == 3.0, "constant" )
	session.budget_s = 4.0


func _run_test() -> int:
	session.check( session.budget_s == 4.0, "replaced" )
	return session.runcode
