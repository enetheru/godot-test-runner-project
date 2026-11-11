@tool
extends TR_Base

## The primary TextServer is installed. TextServer itself is not a singleton.

const DESCRIPTION: String = "The primary TextServer is installed. TextServer itself is not a singleton."

func _run_test() -> RetCode:
	var text_server:TextServer = TextServerManager.get_primary_interface()
	TEST_TRUE(text_server != null, "TextServer exists")
	return runcode as RetCode
