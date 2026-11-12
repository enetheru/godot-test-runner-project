@tool
extends TR_Case

## Setup builds a detached tree. The body adds that tree's root.

const DESCRIPTION: String = "Setup builds a detached tree. The body adds that tree's root."

const NEEDS_TREE: bool = true

# Scene callbacks. The call is the cost.
const _Callbacks: GDScript = preload( "res://cases/scene_tree/gdscript/node_callbacks.gd" )

# How many nodes setup builds, counting the root.
const _COUNT: int = 256


# ██████  ██████   ██████  ██████  ███████ ██████  ████████ ██ ███████ ███████ #
# ██   ██ ██   ██ ██    ██ ██   ██ ██      ██   ██    ██    ██ ██      ██      #
# ██████  ██████  ██    ██ ██████  █████   ██████     ██    ██ █████   ███████ #
# ██      ██   ██ ██    ██ ██      ██      ██   ██    ██    ██ ██           ██ #
# ██      ██   ██  ██████  ██      ███████ ██   ██    ██    ██ ███████ ███████ #
func                        ________PROPERTIES_______              ()->void:pass

# Detached root. Setup parents the other nodes onto it.
var _root: Node


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _setup() -> Error:
	_root = _Callbacks.new()
	_root.name = "hierarchy"
	for i: int in _COUNT - 1:
		var child: Node = _Callbacks.new()
		child.name = "child_%d" % i
		_root.add_child( child )

	return OK


func _run_test() -> int:
	var scene_root: Node = session.tree.root
	scene_root.add_child( _root )

	session.TEST_TRUE( _root.is_inside_tree(), "root entered" )
	session.TEST_EQ( scene_root, _root.get_parent(), "root parent" )
	session.TEST_EQ( _COUNT - 1, _root.get_child_count(), "children stayed attached" )
	session.TEST_TRUE( _root.get_child( 0 ).is_inside_tree(), "child entered with the root" )
	return session.runcode


func _cleanup() -> Error:
	if is_instance_valid( _root ):
		_root.free()

	_root = null
	return OK
