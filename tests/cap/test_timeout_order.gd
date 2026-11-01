@tool
extends TracyCapture

## The body parks on a signal nobody emits. The cap ends the run.
##
## The trace is this script's name plus [code].tracy[/code], in this folder.
## [code]cap: body parked[/code] is in the trace. [code]cap: cleanup ran[/code] is not,
## because a timeout skips cleanup. The stored result is the timeout, not a pass.

signal _never


func _setup() -> Error:
	# [TracyCapture] arms a long cap before this. This run wants the short one.
	max_runtime_s = 0.4
	_profiler_message("cap: setup set")
	return OK


func _run_test() -> int:
	_profiler_message("cap: body parked")
	await _never
	_profiler_message("cap: body resumed")
	return RetCode.TEST_OK


func _cleanup() -> Error:
	_profiler_message("cap: cleanup ran")
	return OK
