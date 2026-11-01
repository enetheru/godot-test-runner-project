@tool
extends TracyCapture

## A deferred call runs on the next idle, after the node it closed over was freed.
##
## The trace is this script's name plus [code].tracy[/code], in this folder.
## The callable is not bound to the node, so the flush still runs and can see the free.

var _order:PackedStringArray = PackedStringArray()


func _run_test() -> int:
	var node := Node.new()
	node.name = "deferred_after_free"
	scene_tree.root.add_child(node)
	var late := func() -> void:
		var alive := is_instance_valid(node)
		_mark("instance: late sees node" if alive else "instance: late sees freed node")
	late.call_deferred()
	_mark("instance: body queued late call")
	node.free()
	_mark("instance: body freed")
	await scene_tree.process_frame
	_mark("instance: body after flush")
	TEST_TRUE(_order.has("instance: late sees freed node"), "deferred call saw the freed node")
	return runcode


func _mark(step:String) -> void:
	if not _order.append(step):
		TEST_TRUE(false, "mark stored " + step)
		return
	_profiler_message(step)
