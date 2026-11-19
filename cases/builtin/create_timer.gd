@tool
extends TR_Case

## SceneTree.create_timer flags. Cleanup clears every timer the body made.

const NEEDS_TREE: bool = true

var _timers: Array[SceneTreeTimer] = []


func _title() -> String:
	return "SceneTree.create_timer"


func _description() -> String:
	return "SceneTree.create_timer with process_always, physics, and ignore_time_scale. Cleanup clears each one."


func _run_test() -> int:
	_create_default()
	_read_time_left()
	_create_while_paused()
	_create_physics()
	_create_ignore_time_scale()
	_listen()
	return TR_CaseSession.TEST_OK


func _cleanup() -> Error:
	for scene_timer: SceneTreeTimer in _timers:
		if scene_timer.timeout.is_connected( _on_timeout ):
			scene_timer.timeout.disconnect( _on_timeout )
		scene_timer.time_left = 0.0

	_timers.clear()
	return OK


func _create_default() -> void:
	# process_always defaults to on.
	_keep( session.tree.create_timer( 1.0 ) )


func _read_time_left() -> void:
	var _left: float = _timers[ 0 ].time_left


func _create_while_paused() -> void:
	_keep( session.tree.create_timer( 1.0, false ) )


func _create_physics() -> void:
	_keep( session.tree.create_timer( 1.0, false, true, false ) )


func _create_ignore_time_scale() -> void:
	_keep( session.tree.create_timer( 1.0, false, false, true ) )


func _listen() -> void:
	_timers[ 0 ].timeout.connect( _on_timeout )


func _keep( scene_timer: SceneTreeTimer ) -> void:
	_timers.append( scene_timer )


func _on_timeout() -> void:
	pass
