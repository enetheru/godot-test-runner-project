@tool
extends TR_Case

## One Timer node. Setup adds it. The body walks its controls. Cleanup frees it.

const NEEDS_TREE: bool = true

var _timer: Timer


func _title() -> String:
	return "Timer node"


func _description() -> String:
	return "One Timer node. Setup adds it. The body walks start, pause, time scale, process callback, and stop. Cleanup frees it."


func _setup() -> Error:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = 5.0
	session.tree.root.add_child( _timer )
	return OK


func _run_test() -> int:
	_read_setup()
	_start()
	_read_running()
	_pause()
	_read_paused()
	_unpause()
	_ignore_time_scale()
	_read_time_scale()
	_use_physics()
	_use_idle()
	_stop()
	_start_with_time()
	_stop()
	_listen()
	_drop_listen()
	_autostart()
	return TR_CaseSession.TEST_OK


func _cleanup() -> Error:
	_drop_listen()
	if _timer == null:
		return OK

	var node: Timer = _timer
	_timer = null
	node.free()
	return OK


func _read_setup() -> void:
	var _one_shot: bool = _timer.one_shot
	var _wait: float = _timer.wait_time


func _start() -> void:
	_timer.start()


func _read_running() -> void:
	var _stopped: bool = _timer.is_stopped()
	var _left: float = _timer.time_left


func _pause() -> void:
	_timer.paused = true


func _read_paused() -> void:
	var _paused: bool = _timer.is_paused()


func _unpause() -> void:
	_timer.paused = false


func _ignore_time_scale() -> void:
	_timer.ignore_time_scale = true


func _read_time_scale() -> void:
	var _ignoring: bool = _timer.is_ignoring_time_scale()


func _use_physics() -> void:
	_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS


func _use_idle() -> void:
	_timer.process_callback = Timer.TIMER_PROCESS_IDLE


func _stop() -> void:
	_timer.stop()


func _start_with_time() -> void:
	_timer.start( 5.0 )


func _listen() -> void:
	if _timer.timeout.is_connected( _on_timeout ):
		return
	_timer.timeout.connect( _on_timeout )


func _drop_listen() -> void:
	if _timer == null:
		return
	if _timer.timeout.is_connected( _on_timeout ):
		_timer.timeout.disconnect( _on_timeout )


func _autostart() -> void:
	_timer.autostart = true
	var _armed: bool = _timer.has_autostart()
	_timer.autostart = false


func _on_timeout() -> void:
	pass
