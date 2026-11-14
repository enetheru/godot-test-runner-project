@tool
extends TR_Case

## With a tree, one frame and a parented node pass, and a short budget times out.
## Without a tree, each of those bodies is refused.

const Drive = preload( "drive.gd" )

# The planted timeout waits, and capture stays open for the whole case.
const BUDGET_S: float = 20.0


class Frame extends TR_Case:
	const NEEDS_TREE: bool = true

	func _run_test() -> int:
		await session.tree.process_frame
		session.check( true, "frame" )
		return session.runcode


class Owned extends TR_Case:
	const NEEDS_TREE: bool = true

	var node: Node

	func _setup() -> Error:
		node = Node.new()
		node.name = "regression_span"
		session.tree.root.add_child( node )
		return OK

	func _run_test() -> int:
		session.check( is_instance_valid( node ), "node" )
		session.check( node.get_parent() == session.tree.root, "root" )
		return session.runcode

	func _cleanup() -> Error:
		if is_instance_valid( node ):
			node.free()
		node = null
		return OK


class Budget extends TR_Case:
	const NEEDS_TREE: bool = true
	const BUDGET_S: float = 0.25

	func _run_test() -> int:
		await session.tree.create_timer( 0.75 ).timeout
		return TR_CaseSession.TEST_OK


func _description() -> String:
	return "With a tree, one frame and a parented node pass, and a short budget times out. Without a tree, each of those bodies is refused."


func _run_test() -> int:
	var frame_word: String = "refused"
	var owned_word: String = "refused"
	var budget_word: String = "refused"
	if session.tree != null:
		frame_word = "pass"
		owned_word = "pass"
		budget_word = "timeout"

	await _watch( Frame.new(), frame_word )
	await _watch( Owned.new(), owned_word )
	await _watch( Budget.new(), budget_word )
	return session.runcode


func _watch( body: TR_Case, expect: String ) -> void:
	var got: String = await Drive.run( session, body )
	session.check( got == expect, expect )
