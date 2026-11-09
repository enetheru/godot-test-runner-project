@tool
extends TestBase

## [method Node.queue_free] leaves the node in the tree until the frame flushes.
##
## The trace is this script's name plus [code].tracy[/code], in this folder.
## The next look on this same frame still finds it. The look after one frame does not.

const _NAME := "suite_same_frame"

var _order:PackedStringArray = PackedStringArray()


func _run_test() -> int:
	var node := Node.new()
	node.name = _NAME
	scene_tree.root.add_child(node)
	_mark("suite: phase 1 queue_free")
	node.queue_free()

	var still := scene_tree.root.get_node_or_null(_NAME)
	_mark("suite: phase 2 same frame still sees node" if still != null else "suite: phase 2 same frame already gone")
	TEST_TRUE(still != null, "queue_free is still visible this frame")

	await scene_tree.process_frame
	var after := scene_tree.root.get_node_or_null(_NAME)
	_mark("suite: phase 2 after frame gone" if after == null else "suite: phase 2 after frame still there")
	TEST_TRUE(after == null, "gone after one frame")
	TEST_TRUE(_order.has("suite: phase 2 after frame gone"), "flush mark")
	return runcode


func _mark(step:String) -> void:
	# append returns the error. OK is 0, so false means the step was stored.
	if _order.append(step):
		TEST_TRUE(false, "mark stored " + step)
		return
	_profiler_message(step)
