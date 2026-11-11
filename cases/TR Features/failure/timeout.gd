@tool
extends TR_Case

## The budget is shorter than the wait.
## The host reports timeout. The script host refuses this before the body.

const DESCRIPTION: String = "The budget is shorter than the wait. The host reports timeout. The script host refuses this before the body."

const NEEDS_TREE: bool = true

const BUDGET_S: float = 0.25


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _run_test() -> int:
	await session.tree.create_timer( 0.75 ).timeout
	return TR_CaseSession.TEST_OK
