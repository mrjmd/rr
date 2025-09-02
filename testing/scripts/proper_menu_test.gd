extends SceneTree
## Proper menu test that inherits from SceneTree for --script usage

var test_step: int = 0
var screenshots_taken: int = 0

func _initialize() -> void:
	print("=== PROPER MENU TEST STARTING ===")
	print("This test will capture real screenshots")
	
func _finalize() -> void:
	print("=== TEST COMPLETE ===")
	print("Screenshots taken: %d" % screenshots_taken)

func _process(_delta: float) -> bool:
	# This won't work with --script, we need a different approach
	return false