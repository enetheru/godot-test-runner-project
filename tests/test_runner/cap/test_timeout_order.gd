@tool
extends TR_Base

## The body parks on a signal nobody emits. The cap ends the run.

const DESCRIPTION: String = "The body parks on a signal nobody emits. The cap ends the run."
##
## The trace is this script's name, the run kind, and [code].tracy[/code], in this folder.
## [code]cap: body parked[/code] is in the trace. [code]cap: cleanup ran[/code] is not,
## because a timeout skips cleanup. The stored result is the timeout, not a pass.

signal _never


func _configure() -> void:
	harness_time_s = 0.4


func _setup() -> Error:
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
