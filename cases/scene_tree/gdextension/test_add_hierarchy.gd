@tool
extends TR_Case

## Same body as the GDScript hierarchy test. The tree and the add_child live in SceneTreeAddHierarchy.

const DESCRIPTION: String = "Same body as the GDScript hierarchy test. The tree and the add_child live in SceneTreeAddHierarchy."

const NEEDS_TREE: bool = true

# Expected node count, counting the root. The worker builds this many.
const _COUNT: int = 256


# ██████  ██████   ██████  ██████  ███████ ██████  ████████ ██ ███████ ███████ #
# ██   ██ ██   ██ ██    ██ ██   ██ ██      ██   ██    ██    ██ ██      ██      #
# ██████  ██████  ██    ██ ██████  █████   ██████     ██    ██ █████   ███████ #
# ██      ██   ██ ██    ██ ██      ██      ██   ██    ██    ██ ██           ██ #
# ██      ██   ██  ██████  ██      ███████ ██   ██    ██    ██ ███████ ███████ #
func                        ________PROPERTIES_______              ()->void:pass

# Native worker. Setup builds the tree. Cleanup frees it.
var _work: SceneTreeAddHierarchy


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _setup() -> Error:
	_work = SceneTreeAddHierarchy.new()
	_work.setup()
	return OK


func _run_test() -> int:
	_work.run( session.tree.root )

	session.TEST_TRUE( _work.is_root_inside_tree(), "root entered" )
	session.TEST_EQ( session.tree.root, _work.get_root_parent(), "root parent" )
	session.TEST_EQ( _COUNT - 1, _work.get_child_count(), "children stayed attached" )
	session.TEST_TRUE( _work.is_first_child_inside_tree(), "child entered with the root" )
	return session.runcode


func _cleanup() -> Error:
	if _work != null:
		_work.cleanup()
		_work = null

	return OK
