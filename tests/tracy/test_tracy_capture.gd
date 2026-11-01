@tool
extends TestBase

## One timeline mark. The capture is on only when the host installed it.
##
## The trace is this script's name plus [code].tracy[/code], in this folder.


## Mark the timeline.
func _run_test() -> int:
	# The message is the mark to search for in the capture.
	_profiler_message("tracy capture")
	var profiler:Variant = Engine.get_singleton(&'Profiler')
	TEST_TRUE(profiler != null, "profiler client")
	return runcode
