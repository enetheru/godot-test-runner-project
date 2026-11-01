@tool
extends TracyCapture

## The body pushes an editor toast after the runner has left the host's flush.
##
## This build has no script-visible [EditorProgress]. [EditorToaster] is the
## editor call the body can make instead. The trace is this script's name plus
## [code].tracy[/code], in this folder. The marks bracket [method EditorToaster.push_toast].

var _order:PackedStringArray = PackedStringArray()


func _run_test() -> int:
	_mark("reenter: before toast")
	var toaster:EditorToaster = EditorInterface.get_editor_toaster()
	TEST_TRUE(toaster != null, "editor toaster")
	if toaster == null:
		return runcode
	toaster.push_toast("failure case: editor re-enters")
	_mark("reenter: toast pushed")
	TEST_TRUE(_order.has("reenter: toast pushed"), "toast mark")
	return runcode


func _mark(step:String) -> void:
	if not _order.append(step):
		TEST_TRUE(false, "mark stored " + step)
		return
	_profiler_message(step)
