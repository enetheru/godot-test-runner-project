@tool
extends TR_Case

## Same body as the GDScript add-each test. The nodes and the add_child loop live in SceneTreeAddEach.

const DESCRIPTION: String = "Same body as the GDScript add-each test. The nodes and the add_child loop live in SceneTreeAddEach."

const NEEDS_TREE: bool = true

# Expected node count. The worker builds this many.
const _COUNT: int = 256


# ██████  ██████   ██████  ██████  ███████ ██████  ████████ ██ ███████ ███████ #
# ██   ██ ██   ██ ██    ██ ██   ██ ██      ██   ██    ██    ██ ██      ██      #
# ██████  ██████  ██    ██ ██████  █████   ██████     ██    ██ █████   ███████ #
# ██      ██   ██ ██    ██ ██      ██      ██   ██    ██    ██ ██           ██ #
# ██      ██   ██  ██████  ██      ███████ ██   ██    ██    ██ ███████ ███████ #
func                        ________PROPERTIES_______              ()->void:pass

# Native worker. Setup builds the nodes. Cleanup frees them.
var _work: SceneTreeAddEach


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _setup() -> Error:
	_work = SceneTreeAddEach.new()
	_work.setup()
	return OK


func _run_test() -> int:
	_work.run( session.tree.root )

	session.TEST_EQ( _COUNT, _work.get_built_count(), "built count" )
	session.TEST_TRUE( _work.is_first_inside_tree(), "first entered" )
	session.TEST_EQ( session.tree.root, _work.get_first_parent(), "first parent" )
	session.TEST_TRUE( _work.is_last_inside_tree(), "last entered" )
	session.TEST_EQ( session.tree.root, _work.get_last_parent(), "last parent" )
	return session.runcode


func _cleanup() -> Error:
	if _work != null:
		_work.cleanup()
		_work = null

	return OK
