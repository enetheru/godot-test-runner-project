@tool
extends TR_Base

## Setup builds a detached tree. The body adds that tree's root.

const DESCRIPTION: String = "Setup builds a detached tree. The body adds that tree's root."
## Each node carries [code]node_callbacks.gd[/code].

const _Callbacks:GDScript = preload("res://tests/scene_tree/gdscript/node_callbacks.gd")
const _COUNT:int = 256

var _root:Node


func _setup() -> Error:
	_root = _Callbacks.new()
	_root.name = "hierarchy"
	for i:int in _COUNT - 1:
		var child:Node = _Callbacks.new()
		child.name = "child_%d" % i
		_root.add_child(child)
	return OK


func _run_test() -> RetCode:
	var scene_root:Node = scene_tree.root
	scene_root.add_child(_root)

	TEST_TRUE(_root.is_inside_tree(), "root entered")
	TEST_EQ(scene_root, _root.get_parent(), "root parent")
	TEST_EQ(_COUNT - 1, _root.get_child_count(), "children stayed attached")
	TEST_TRUE(_root.get_child(0).is_inside_tree(), "child entered with the root")
	return runcode as RetCode


func _cleanup() -> Error:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	return OK
