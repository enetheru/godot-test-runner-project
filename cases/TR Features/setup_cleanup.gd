@tool
extends TR_Case

## Setup parents a node. The body uses it. Cleanup frees it.

const DESCRIPTION: String = "Setup parents a node. The body uses it. Cleanup frees it."

const NEEDS_TREE: bool = true


# ██████  ██████   ██████  ██████  ███████ ██████  ████████ ██ ███████ ███████ #
# ██   ██ ██   ██ ██    ██ ██   ██ ██      ██   ██    ██    ██ ██      ██      #
# ██████  ██████  ██    ██ ██████  █████   ██████     ██    ██ █████   ███████ #
# ██      ██   ██ ██    ██ ██      ██      ██   ██    ██    ██ ██           ██ #
# ██      ██   ██  ██████  ██      ███████ ██   ██    ██    ██ ███████ ███████ #
func                        ________PROPERTIES_______              ()->void:pass

# Node parented in setup and freed in cleanup.
var _node: Node


#      ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████     #
#     ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██          #
#     ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████     #
#     ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██     #
#      ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████     #
func                        ________OVERRIDES________              ()->void:pass

func _setup() -> Error:
	_node = Node.new()
	_node.name = "tr_features_node"
	session.tree.root.add_child( _node )
	return OK


func _run_test() -> int:
	session.check( is_instance_valid( _node ), "node from setup" )
	session.check( _node.get_parent() == session.tree.root, "parented to the root" )
	return session.runcode


func _cleanup() -> Error:
	if is_instance_valid( _node ):
		_node.free()

	_node = null
	return OK
