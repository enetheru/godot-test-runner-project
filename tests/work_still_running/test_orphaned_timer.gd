@tool
extends TracyCapture

## A timer armed in the body fires after cleanup has freed the node.
##
## The trace is this script's name plus [code].tracy[/code], in this folder.
## Marks: body arms, body returns, cleanup frees, the late timer, cleanup sees it.

var _node:Node
var _order:PackedStringArray = PackedStringArray()


func _setup() -> Error:
	_node = Node.new()
	_node.name = "orphaned_timer_node"
	scene_tree.root.add_child(_node)
	return OK


## Arm a one-shot timer and return without awaiting it.
func _run_test() -> int:
	# Same stack as cleanup. The timer cannot fire until this function yields.
	var late := scene_tree.create_timer(0.05)
	var connected := late.timeout.connect(_on_late)
	if connected != OK:
		TEST_TRUE(false, "late timer connect")
		return runcode
	_mark("orphaned: body arm")
	_mark("orphaned: body return")
	return runcode


## The node is already freed. The mark is the late fiber.
func _on_late() -> void:
	var alive := is_instance_valid(_node)
	_mark("orphaned: late timer sees node" if alive else "orphaned: late timer sees freed node")


## Free first, then wait long enough for the timer to land inside the capture.
func _cleanup() -> Error:
	_mark("orphaned: cleanup free")
	if is_instance_valid(_node):
		_node.free()
	_node = null
	await scene_tree.create_timer(0.2).timeout
	_mark("orphaned: cleanup saw late")
	TEST_TRUE(_saw("orphaned: late timer sees freed node"), "late timer ran after the free")
	return OK


func _mark(step:String) -> void:
	if not _order.append(step):
		TEST_TRUE(false, "mark stored " + step)
		return
	_profiler_message(step)


func _saw(step:String) -> bool:
	return _order.has(step)
