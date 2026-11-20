@tool
extends TR_Case

## Neighbouring cases share a launch. OWN_PROCESS is alone. A folder stays with the neighbours.


func _description() -> String:
	return "Neighbouring cases share a launch. OWN_PROCESS is alone. A folder stays with the neighbours."


func _run_test() -> int:
	var share:String = "res://cases/regression/values.gd"
	var own:String = "res://cases/regression/own_process.gd"
	var folder:String = "res://cases/regression"
	var paths:PackedStringArray = PackedStringArray( [ share, own, share, folder ] )

	var batches:Array[PackedStringArray] = TR_CaseSession.launch_batches( paths )
	session.check( batches.size() == 3, "three launches" )
	if batches.size() == 3:
		session.check( batches[ 0 ].size() == 1 and batches[ 0 ][ 0 ] == share, "leading share" )
		session.check( batches[ 1 ].size() == 1 and batches[ 1 ][ 0 ] == own, "own launch" )
		session.check( batches[ 2 ].size() == 2, "tail" )
		if batches[ 2 ].size() == 2:
			session.check( batches[ 2 ][ 0 ] == share, "second share" )
			session.check( batches[ 2 ][ 1 ] == folder, "folder" )

	session.check( TR_CaseSession.owns_process( own ), "own flag" )
	session.check( not TR_CaseSession.owns_process( share ), "share flag" )
	session.check( not TR_CaseSession.owns_process( folder ), "folder flag" )
	return session.runcode
