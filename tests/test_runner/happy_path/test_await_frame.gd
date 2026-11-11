@tool
extends TR_Base

## A body may await. This one resumes on the next frame and then passes.

const DESCRIPTION: String = "A body may await. This one resumes on the next frame and then passes."

func _run_test() -> RetCode:
	var resumed := false
	await scene_tree.process_frame

	resumed = true
	TEST_TRUE(resumed, "resumed after one frame")
	return runcode as RetCode
