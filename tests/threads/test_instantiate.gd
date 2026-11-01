@tool
extends TestBase

## Instantiate one detached [PackedScene] off the main thread.
##
## The scene is a bare [Node]. The trace is this script's name plus
## [code].tracy[/code], in this folder.

const _SCENE:PackedScene = preload("res://tests/threads/off_thread.tscn")

var _is_main:bool = false
var _thread:Thread

signal _built(node:Node)


func _setup() -> Error:
	_thread = Thread.new()
	return OK


## Build the scene on a [Thread]. The fiber waits. The main thread does not.
func _run_test() -> int:
	# The signal carries the node. [method Thread.wait_to_finish] only joins after that.
	_profiler_message("instantiate off thread")
	var started:Error = _thread.start(_instantiate)
	if started != OK:
		TEST_TRUE(false, "thread start")
		return runcode

	var made:Variant = await _built
	TEST_FALSE(_is_main, "off the main thread")
	TEST_TRUE(made is Node, "handed back")
	if made is Node:
		var node:Node = made
		TEST_TRUE(not node.is_inside_tree(), "still detached")
		node.free()
	return runcode


## [method PackedScene.instantiate] on the worker thread.
func _instantiate() -> void:
	# The scene was loaded on the main thread. This thread only builds it.
	_is_main = Thread.is_main_thread()
	var node:Node = _SCENE.instantiate()
	_built.emit.call_deferred(node)


func _cleanup() -> Error:
	_thread.wait_to_finish()
	_thread = null
	return OK
