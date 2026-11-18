@tool
extends TR_Case

## An editor-only body runs when this process is the editor.
## A main-scene body runs only when that scene was the one started.
## Anything else is refused, and this case still passes.

const Drive = preload( "drive.gd" )


class EditorBody extends TR_Case:
	const EDITOR_ONLY: bool = true

	func _run_test() -> int:
		session.check( session.host == TR_CaseSession.Host.EDITOR, "host" )
		session.check( session.hint, "hint" )
		return session.runcode


class MainBody extends TR_Case:
	const NEEDS_MAIN_SCENE: bool = true

	func _run_test() -> int:
		session.check( session.main_scene_started, "main scene" )
		return session.runcode


func _description() -> String:
	return "An editor-only body runs when this process is the editor. A main-scene body runs only when that scene was the one started. Anything else is refused, and this case still passes."


func _run_test() -> int:
	var editor_word:Status = Status.REFUSED
	if session.hint and session.host == TR_CaseSession.Host.EDITOR:
		editor_word = Status.PASS

	var main_word:Status = Status.REFUSED
	if session.tree != null and session.main_scene_started:
		main_word = Status.PASS

	await _watch( EditorBody.new(), editor_word )
	await _watch( MainBody.new(), main_word )
	return session.runcode


func _watch( body: TR_Case, expect:Status ) -> void:
	var got:int = await Drive.run( session, body )
	session.check( got == expect, str(Status.find_key(expect))  )
