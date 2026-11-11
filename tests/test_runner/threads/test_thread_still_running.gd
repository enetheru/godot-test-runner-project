@tool
extends TR_Base

## The body returns while a worker is still blocked. Cleanup is what joins it.

const DESCRIPTION: String = "The body returns while a worker is still blocked. Cleanup is what joins it."
##
## The trace is this script's name, the run kind, and [code].tracy[/code], in this folder.
## The worker does not call into the tree. The marks are all on the main thread.

var _thread:Thread
var _gate:Semaphore
var _order:PackedStringArray = PackedStringArray()


func _setup() -> Error:
	_gate = Semaphore.new()
	_thread = Thread.new()
	var started := _thread.start(_worker)
	if started != OK:
		TEST_TRUE(false, "thread start")
		return started
	_mark("thread: setup started")
	return OK


## The worker stays on the semaphore until cleanup posts it.
func _run_test() -> int:
	var alive := _thread.is_started()
	_mark("thread: body still running" if alive else "thread: body already finished")
	TEST_TRUE(alive, "worker still running when the body returns")
	return runcode


func _worker() -> void:
	_gate.wait()


## Join here so the process is not left with a live thread.
func _cleanup() -> Error:
	_mark("thread: cleanup joins")
	_gate.post()
	var _joined:Variant = _thread.wait_to_finish()
	_mark("thread: cleanup joined")
	_thread = null
	TEST_TRUE(_order.has("thread: body still running"), "body saw the worker")
	TEST_TRUE(_order.has("thread: cleanup joined"), "cleanup joined")
	return OK


func _mark(step:String) -> void:
	# append returns the error. OK is 0, so false means the step was stored.
	if _order.append(step):
		TEST_TRUE(false, "mark stored " + step)
		return
	_profiler_message(step)
