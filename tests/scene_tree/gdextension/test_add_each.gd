@tool
extends TR_Base

## Same body as tests/scene_tree/gdscript/test_add_each.gd.

const DESCRIPTION: String = "Same body as the GDScript add-each test. The nodes and the add_child loop live in SceneTreeAddEach."
## The nodes and the add_child loop live in SceneTreeAddEach.

const _COUNT:int = 256

var _work:SceneTreeAddEach


func _setup() -> Error:
	_work = SceneTreeAddEach.new()
	_work.setup()
	return OK


func _run_test() -> RetCode:
	_work.run(scene_tree.root)

	TEST_EQ(_COUNT, _work.get_built_count(), "built count")
	TEST_TRUE(_work.is_first_inside_tree(), "first entered")
	TEST_EQ(scene_tree.root, _work.get_first_parent(), "first parent")
	TEST_TRUE(_work.is_last_inside_tree(), "last entered")
	TEST_EQ(scene_tree.root, _work.get_last_parent(), "last parent")
	return runcode as RetCode


func _cleanup() -> Error:
	if _work != null:
		_work.cleanup()
		_work = null
	return OK
