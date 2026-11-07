@tool
extends TestBase

## Setup builds detached nodes. The body adds each one to the scene root.
## Each node carries [code]node_callbacks.gd[/code].

const _Callbacks:GDScript = preload("res://tests/scene_tree/gdscript/node_callbacks.gd")
const _COUNT:int = 256

var _nodes:Array[Node] = []


func _setup() -> Error:
	for i:int in _COUNT:
		var node:Node = _Callbacks.new()
		node.name = "each_%d" % i
		_nodes.append(node)
	return OK


func _run_test() -> RetCode:
	var root:Node = scene_tree.root
	for node:Node in _nodes:
		root.add_child(node)

	TEST_EQ(_COUNT, _nodes.size(), "built count")
	TEST_TRUE(_nodes[0].is_inside_tree(), "first entered")
	TEST_EQ(root, _nodes[0].get_parent(), "first parent")
	TEST_TRUE(_nodes[_COUNT - 1].is_inside_tree(), "last entered")
	TEST_EQ(root, _nodes[_COUNT - 1].get_parent(), "last parent")
	return runcode as RetCode


func _cleanup() -> Error:
	for node:Node in _nodes:
		if is_instance_valid(node):
			node.free()
	_nodes.clear()
	return OK
