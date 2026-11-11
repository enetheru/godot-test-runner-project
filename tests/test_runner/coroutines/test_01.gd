@tool
extends TR_Base

## Override this function to perform setup prior to testing.

const DESCRIPTION: String = "Await a signal, a function state, and a plain value."

func _setup() -> Error:
	#OS.delay_usec(100)
	return OK


## Override this function to perform cleanup post testing.
func _cleanup() -> Error:
	#OS.delay_usec(100)
	return OK


func _run_test() -> int:
	#Log.trace({}, self)
	#Profiler.message("simplest case")
	#OS.delay_usec(100)
	return runcode

# Only three possible wait conditions
# - signal
# - function state
# - value

# If that value is a Signal, the function stops.
# The VM connects a one-shot callback, returns a function state to the caller,
# and the function continues later when the signal is emitted.
# await step in walk is this case. step was built as Signal(emitter, "step").
#
# If that value is another GDScript function that has already stopped at its
# own await, the VM treats it as that function's completed signal.
# The caller stops too, and resumes when the other function finishes.
#
# Anything else is a value: an int, a String, a node, null,
# or the return value of a function that ran to the end and returned normally.
# The VM stores that value and runs the next line. The function does not stop.
# No fiber is created. These two scripts both do that:
