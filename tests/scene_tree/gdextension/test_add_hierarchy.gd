@tool
extends TR_Base

## Same body as tests/scene_tree/gdscript/test_add_hierarchy.gd.
## The tree and the add_child live in SceneTreeAddHierarchy.

const _COUNT:int = 256

var _work:SceneTreeAddHierarchy


func _setup() -> Error:
	_work = SceneTreeAddHierarchy.new()
	_work.setup()
	return OK


func _run_test() -> RetCode:
	_work.run(scene_tree.root)

	TEST_TRUE(_work.is_root_inside_tree(), "root entered")
	TEST_EQ(scene_tree.root, _work.get_root_parent(), "root parent")
	TEST_EQ(_COUNT - 1, _work.get_child_count(), "children stayed attached")
	TEST_TRUE(_work.is_first_child_inside_tree(), "child entered with the root")
	return runcode as RetCode


func _cleanup() -> Error:
	if _work != null:
		_work.cleanup()
		_work = null
	return OK
