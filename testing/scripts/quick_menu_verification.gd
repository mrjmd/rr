extends SceneTree
## Quick MenuManager verification

func _ready():
	print("🚀 Quick MenuManager Verification Test")
	print("====================================")
	
	await process_frame
	
	if not root.has_node("/root/MenuManager"):
		print("❌ ERROR: MenuManager not available as singleton")
		quit(1)
		return
	
	var menu_manager = root.get_node("/root/MenuManager")
	print("✅ MenuManager singleton accessible")
	print("   Type: ", typeof(menu_manager))
	print("   Name: ", menu_manager.name)
	
	print("\nChecking required methods:")
	var required_methods = [
		"open_menu",
		"close_current_menu", 
		"go_back",
		"close_all_menus",
		"get_current_menu",
		"get_menu_stack",
		"register_menu"
	]
	
	var all_methods_ok = true
	for method in required_methods:
		if menu_manager.has_method(method):
			print("  ✅ ", method, " - OK")
		else:
			print("  ❌ ", method, " - MISSING")
			all_methods_ok = false
	
	print("\nChecking signals:")
	var required_signals = [
		"menu_opened",
		"menu_closed",
		"menu_stack_changed",
		"transition_started",
		"transition_completed"
	]
	
	var all_signals_ok = true
	for signal_name in required_signals:
		if menu_manager.has_signal(signal_name):
			print("  ✅ ", signal_name, " - OK")
		else:
			print("  ❌ ", signal_name, " - MISSING")
			all_signals_ok = false
	
	print("\nMenuManager debug info:")
	if menu_manager.has_method("debug_print_state"):
		menu_manager.debug_print_state()
	else:
		print("  Debug method not available")
	
	print("\n==========================================")
	if all_methods_ok and all_signals_ok:
		print("🎉 MenuManager verification PASSED!")
		print("✅ All required methods and signals present")
		print("✅ Ready for menu navigation implementation")
		quit(0)
	else:
		print("❌ MenuManager verification FAILED!")
		print("Some required methods or signals are missing")
		quit(1)