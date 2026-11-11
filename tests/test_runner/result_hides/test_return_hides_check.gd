@tool
extends TR_Base

## A failing check runs, then the body returns the pass value.

const DESCRIPTION: String = "A failing check runs, then the body returns the pass value."
##
## The trace is this script's name, the run kind, and [code].tracy[/code], in this folder.
## The marks stay in order: before the check, after the check, the pass return.
## The host stores that return. The planted check is in the output either way.

var _order:PackedStringArray = PackedStringArray()


func _run_test() -> int:
	_mark("hides: before check")
	TEST_TRUE(false, "planted failure")
	_mark("hides: after check")
	_mark("hides: return pass token")
	TEST_TRUE(_order.has("hides: after check"), "check mark")
	TEST_TRUE(_order.has("hides: return pass token"), "return mark")
	return RetCode.TEST_OK


func _mark(step:String) -> void:
	# append returns the error. OK is 0, so false means the step was stored.
	if _order.append(step):
		TEST_TRUE(false, "mark stored " + step)
		return
	_profiler_message(step)
