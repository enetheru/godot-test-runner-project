@tool
extends Resource

## Trim lists for the failure matrix.
## A place or a trigger missing from the lists does not run.
## A listed pair with no expected status is reported and skipped.


@export var places:PackedStringArray = PackedStringArray( [
	"pre", "setup", "run", "cleanup", "post",
] )

@export var triggers:PackedStringArray = PackedStringArray( [
	"retcode", "runcode_manual", "runcode_check",
] )
