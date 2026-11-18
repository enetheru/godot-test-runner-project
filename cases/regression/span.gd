@tool
extends TR_Case

## With a tree, one frame and a parented node pass, and a short budget times out.
## Without a tree, each of those bodies is refused.

const Drive = preload( "drive.gd" )


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

	static func _static_init() -> void:
		config.budget_s = 0.25

	func _run_test() -> int:
		await session.tree.create_timer( 0.75 ).timeout
		return TR_CaseSession.TEST_OK


static func _static_init() -> void:
	config.budget_s = 20.0


func _description() -> String:
	return "With a tree, one frame and a parented node pass, and a short budget times out. Without a tree, each of those bodies is refused."


func _run_test() -> int:
	var frame_word:Status = Status.REFUSED
	var owned_word:Status = Status.REFUSED
	var budget_word:Status = Status.REFUSED
	if session.tree != null:
		frame_word = Status.PASS
		owned_word = Status.PASS
		budget_word = Status.TIMEOUT

	await _watch( Frame.new(), frame_word )
	await _watch( Owned.new(), owned_word )
	await _watch( Budget.new(), budget_word )
	return session.runcode


func _watch( body: TR_Case, expect:Status ) -> void:
	var got:int = await Drive.run( session, body )
	session.check( got == expect, str(Status.find_key(expect)) )
