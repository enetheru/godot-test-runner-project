@tool
extends TR_Case

## Setup builds detached nodes. The body adds each one to the scene root.

const DESCRIPTION: String = "Setup builds detached nodes. The body adds each one to the scene root."

const NEEDS_TREE: bool = true

# Scene callbacks. The call is the cost.
const _Callbacks: GDScript = preload( "res://cases/scene_tree/gdscript/node_callbacks.gd" )

# How many nodes setup builds.
const _COUNT: int = 256


# ██████  ██████   ██████  ██████  ███████ ██████  ████████ ██ ███████ ███████ #
# ██   ██ ██   ██ ██    ██ ██   ██ ██      ██   ██    ██    ██ ██      ██      #
# ██████  ██████  ██    ██ ██████  █████   ██████     ██    ██ █████   ███████ #
# ██      ██   ██ ██    ██ ██      ██      ██   ██    ██    ██ ██           ██ #
# ██      ██   ██  ██████  ██      ███████ ██   ██    ██    ██ ███████ ███████ #
func                        ________PROPERTIES_______              ()->void:pass

# Detached nodes built in setup. The body parents each one.
var _nodes: Array[Node] = []


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _setup() -> Error:
	for i: int in _COUNT:
		var node: Node = _Callbacks.new()
		node.name = "each_%d" % i
		_nodes.append( node )

	return OK


func _run_test() -> int:
	var root: Node = session.tree.root
	for node: Node in _nodes:
		root.add_child( node )

	session.TEST_EQ( _COUNT, _nodes.size(), "built count" )
	session.TEST_TRUE( _nodes[ 0 ].is_inside_tree(), "first entered" )
	session.TEST_EQ( root, _nodes[ 0 ].get_parent(), "first parent" )
	session.TEST_TRUE( _nodes[ _COUNT - 1 ].is_inside_tree(), "last entered" )
	session.TEST_EQ( root, _nodes[ _COUNT - 1 ].get_parent(), "last parent" )
	return session.runcode


func _cleanup() -> Error:
	for node: Node in _nodes:
		if is_instance_valid( node ):
			node.free()

	_nodes.clear()
	return OK
