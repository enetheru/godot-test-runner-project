@tool
extends TR_Base

## Setup parents a node, the body uses it, and cleanup frees it.

var _node:Node


func _setup() -> Error:
	_node = Node.new()
	_node.name = "happy_path_node"
	scene_tree.root.add_child(_node)
	return OK


func _run_test() -> RetCode:
	TEST_TRUE(is_instance_valid(_node), "node from setup")
	TEST_EQ(_node.get_parent(), scene_tree.root, "parented to the root")
	return runcode as RetCode


func _cleanup() -> Error:
	if is_instance_valid(_node):
		_node.free()
	_node = null
	return OK
