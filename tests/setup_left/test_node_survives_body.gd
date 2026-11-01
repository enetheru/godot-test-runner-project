@tool
extends TracyCapture

## Setup parents a node to the root. The body never releases it.
##
## The trace is this script's name plus [code].tracy[/code], in this folder.
## Cleanup is the first place that notices, and then it frees the node.

var _node:Node
var _order:PackedStringArray = PackedStringArray()


func _setup() -> Error:
	_node = Node.new()
	_node.name = "setup_left_node"
	scene_tree.root.add_child(_node)
	_mark("setup: parented")
	return OK


func _run_test() -> int:
	_mark("setup: body leaves node")
	return runcode


## The node is still a child here. Free it after the mark so the suite stays clean.
func _cleanup() -> Error:
	var still := is_instance_valid(_node) and _node.get_parent() == scene_tree.root
	_mark("setup: cleanup still sees node" if still else "setup: cleanup node already gone")
	TEST_TRUE(still, "node still parented at cleanup")
	if is_instance_valid(_node):
		_node.free()
	_node = null
	_mark("setup: cleanup freed")
	TEST_TRUE(_order.has("setup: parented"), "setup mark")
	TEST_TRUE(_order.has("setup: cleanup freed"), "cleanup mark")
	return OK


func _mark(step:String) -> void:
	if not _order.append(step):
		TEST_TRUE(false, "mark stored " + step)
		return
	_profiler_message(step)
