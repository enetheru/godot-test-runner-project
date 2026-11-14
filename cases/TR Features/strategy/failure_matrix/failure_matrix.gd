@tool
extends TR_StrategyScript

## One row. Each cell is its own case and its own case session.
## The resource trims which pairs are asked for.


const OPTS_PATH:String = "res://cases/TR Features/strategy/failure_matrix/failure_matrix.tres"

const PLACES:Array[String] = [
	"config", "pre", "setup", "run", "cleanup", "post",
]

const TRIGGERS:Array[String] = [
	"assert", "retcode", "runcode_manual", "runcode_check",
]

const DEFAULT_PLACES:Array[String] = [
	"pre", "setup", "run", "cleanup", "post",
]

const DEFAULT_TRIGGERS:Array[String] = [
	"retcode", "runcode_manual", "runcode_check",
]

## Expected status, then the sentence. Absent means the pair is not ready.
const EXPECTED:Dictionary = {
	"pre|retcode": [
		"fail",
		"Pre returns an error. The host reports fail and skips the body.",
	],
	"setup|retcode": [
		"setup failed",
		"Setup returns an error and acquires nothing. The host reports setup failed. The body does not run.",
	],
	"run|retcode": [
		"fail",
		"Every check passes. The body returns fail. The host reports fail.",
	],
	"run|runcode_check": [
		"fail",
		"A false check. Returning pass does not clear it. The host reports fail, and the label is an output line.",
	],
	"run|runcode_manual": [
		"fail",
		"The body assigns fail and returns pass. The host reports fail.",
	],
	"cleanup|retcode": [
		"cleanup failed",
		"The body passes. Cleanup returns an error. The host reports cleanup failed.",
	],
	"post|retcode": [
		"fail",
		"The body passes. Post returns an error. The host reports fail.",
	],
}


## Pre or post returns an error. The other side returns OK.
class Gate extends TR_Hook:
	var place:String = ""


	func _pre() -> Error:
		if place == "pre":
			return FAILED

		return OK


	func _post() -> Error:
		if place == "post":
			return FAILED

		return OK


## One planted fault.
class Plant extends TR_Case:
	var place:String = ""
	var trigger:String = ""


	func _configure() -> void:
		if place != "pre" and place != "post":
			return

		var gate := Gate.new()
		gate.place = place
		session.hooks.append( gate )


	func _setup() -> Error:
		if place == "setup" and trigger == "retcode":
			return FAILED

		return OK


	func _run_test() -> int:
		if place != "run":
			if place == "setup":
				session.check( false, "body ran" )
				return session.runcode

			return TR_CaseSession.TEST_OK

		if trigger == "retcode":
			session.check( true, "body" )
			return TR_CaseSession.TEST_FAILED

		if trigger == "runcode_check":
			session.check( 1 + 1 == 2, "arithmetic" )
			session.check( 1 == 2, "one equals two" )
			session.check( true, "later check" )
			return TR_CaseSession.TEST_OK

		if trigger == "runcode_manual":
			session.runcode = TR_CaseSession.TEST_FAILED
			return TR_CaseSession.TEST_OK

		return TR_CaseSession.TEST_OK


	func _cleanup() -> Error:
		if place == "cleanup" and trigger == "retcode":
			return FAILED

		return OK


func _title() -> String:
	return "Failure matrix"


func _description() -> String:
	return "One row. Each cell is its own case session. The resource trims the pairs."


func _children() -> Array:
	var out:Array = []
	for place:String in PLACES:
		for trigger:String in TRIGGERS:
			if not _listed( place, trigger ):
				continue

			var key:String = "%s|%s" % [ place, trigger ]
			var pair:String = "%s / %s" % [ place, trigger ]
			if not EXPECTED.has( key ):
				out.append( { "skip": "%s — no expected status" % pair } )
				continue

			var row:Array = EXPECTED[ key ]
			var plant := Plant.new()
			plant.place = place
			plant.trigger = trigger
			out.append( {
				"name": pair,
				"expect": str( row[ 0 ] ),
				"case": plant,
				"hook_plant": place == "pre" or place == "post",
			} )

	return out


func _listed( place:String, trigger:String ) -> bool:
	return _in_list( _list( "places", DEFAULT_PLACES ), place ) \
		and _in_list( _list( "triggers", DEFAULT_TRIGGERS ), trigger )


func _list( prop:String, fallback:Array[String] ) -> Variant:
	if not ResourceLoader.exists( OPTS_PATH ):
		return fallback

	var opts:Resource = load( OPTS_PATH )
	if opts == null:
		return fallback

	var value:Variant = opts.get( prop )
	if value is PackedStringArray or value is Array:
		return value

	return fallback


func _in_list( value:Variant, item:String ) -> bool:
	if value is PackedStringArray:
		var packed:PackedStringArray = value
		return packed.has( item )

	if value is Array:
		var row:Array = value
		return row.has( item )

	return false
