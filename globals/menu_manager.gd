extends Node
## MenuManager singleton for handling menu navigation and transitions

# Signals
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)
signal menu_stack_changed(stack_size: int)
signal transition_started(from_menu: String, to_menu: String)
signal transition_completed(from_menu: String, to_menu: String)

# Constants
const MENU_LAYER_BASE: int = 200
const MENU_LAYER_INCREMENT: int = 10

# Menu stack and state
var menu_stack: Array[String] = []
var current_menu: String = ""
var menu_instances: Dictionary = {}
var menu_scenes: Dictionary = {}
var is_transitioning: bool = false

# References
var fade_transition: FadeTransition
var game_tree: SceneTree

# Menu scene paths - populated during initialization
var menu_scene_paths: Dictionary = {
	"main_menu": "res://src/scenes/ui/menus/main_menu_simple.tscn",
	"pause_menu": "res://src/scenes/ui/menus/pause_menu.tscn", 
	"settings_menu": "res://src/scenes/ui/menus/settings_menu_standalone.tscn"
}

func _ready() -> void:
	game_tree = get_tree()
	
	# Initialize fade transition system
	_initialize_fade_transition()
	
	# Connect to global signals
	_connect_global_signals()
	
	if OS.is_debug_build():
		print("MenuManager initialized")

func _initialize_fade_transition() -> void:
	"""Initialize the fade transition system"""
	# Check if FadeTransition already exists in the scene
	fade_transition = get_tree().get_first_node_in_group("fade_transition")
	
	if not fade_transition:
		# Load and instance FadeTransition if not found
		var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
		if fade_scene:
			fade_transition = fade_scene.instantiate()
			# Defer adding child to avoid setup conflicts
			get_tree().root.add_child.call_deferred(fade_transition)
			fade_transition.add_to_group("fade_transition")
		else:
			print("WARNING: Could not load FadeTransition scene")
	
	# Defer signal connections to next frame to ensure FadeTransition is ready
	call_deferred("_connect_fade_transition_signals")

func _connect_fade_transition_signals() -> void:
	"""Connect to fade transition signals after it's ready"""
	if fade_transition:
		# Connect transition signals
		if not fade_transition.transition_completed.is_connected(_on_transition_completed):
			fade_transition.transition_completed.connect(_on_transition_completed)
		if not fade_transition.fade_in_completed.is_connected(_on_fade_in_completed):
			fade_transition.fade_in_completed.connect(_on_fade_in_completed)
		
		if OS.is_debug_build():
			print("FadeTransition initialized for MenuManager")

func _connect_global_signals() -> void:
	"""Connect to global event signals"""
	if EventBus:
		if EventBus.has_signal("scene_changed"):
			EventBus.scene_changed.connect(_on_scene_changed)

# Public API Methods

func register_menu(menu_name: String, menu_node: Node) -> void:
	"""Register a menu instance with the manager"""
	if menu_instances.has(menu_name):
		print("WARNING: Menu already registered: ", menu_name)
		return
	
	menu_instances[menu_name] = menu_node
	
	# Set proper layer for menu
	if menu_node is CanvasLayer:
		var layer_index = menu_stack.size()
		menu_node.layer = MENU_LAYER_BASE + (layer_index * MENU_LAYER_INCREMENT)
	
	# Connect menu signals if available
	_connect_menu_signals(menu_name, menu_node)
	
	if OS.is_debug_build():
		print("Menu registered: ", menu_name)

func unregister_menu(menu_name: String) -> void:
	"""Unregister a menu from the manager"""
	if menu_instances.has(menu_name):
		menu_instances.erase(menu_name)
		
		# Remove from stack if present
		if menu_name in menu_stack:
			menu_stack.erase(menu_name)
			menu_stack_changed.emit(menu_stack.size())
		
		if current_menu == menu_name:
			current_menu = ""
	
	if OS.is_debug_build():
		print("Menu unregistered: ", menu_name)

func open_menu(menu_name: String, use_transition: bool = true) -> void:
	"""Open a menu with optional transition"""
	if is_transitioning:
		if OS.is_debug_build():
			print("MenuManager: Ignoring open_menu - transition in progress")
		return
	
	if current_menu == menu_name:
		if OS.is_debug_build():
			print("MenuManager: Menu already open: ", menu_name)
		return
	
	# Play transition sound
	if use_transition and AudioManager:
		AudioManager.play_ui_sound("ui_transition")
	
	# Get or load menu instance
	var menu_instance = _get_or_load_menu(menu_name)
	if not menu_instance:
		print("ERROR: Could not load menu: ", menu_name)
		return
	
	var previous_menu = current_menu
	
	if use_transition and fade_transition:
		is_transitioning = true
		transition_started.emit(previous_menu, menu_name)
		
		# Fade in (to black)
		await fade_transition.fade_in()
		
		# Switch menus during blackout
		_switch_to_menu(menu_name, previous_menu)
		
		# Fade out (reveal new menu)
		await fade_transition.fade_out()
		
		is_transitioning = false
		transition_completed.emit(previous_menu, menu_name)
	else:
		# Immediate switch without transition
		_switch_to_menu(menu_name, previous_menu)
	
	if OS.is_debug_build():
		print("MenuManager: Opened menu: ", menu_name, " (previous: ", previous_menu, ")")

func close_current_menu(use_transition: bool = true) -> void:
	"""Close the currently active menu"""
	if current_menu.is_empty():
		return
	
	var menu_instance = menu_instances.get(current_menu)
	if not menu_instance:
		return
	
	var closing_menu = current_menu
	
	if use_transition and fade_transition and menu_stack.size() > 0:
		is_transitioning = true
		transition_started.emit(closing_menu, "")
		
		# Fade in
		await fade_transition.fade_in()
		
		# Close menu during blackout
		_close_menu_immediate(closing_menu)
		
		# Fade out
		await fade_transition.fade_out()
		
		is_transitioning = false
		transition_completed.emit(closing_menu, current_menu)
	else:
		# Immediate close without transition
		_close_menu_immediate(closing_menu)
	
	if OS.is_debug_build():
		print("MenuManager: Closed menu: ", closing_menu)

func go_back() -> void:
	"""Navigate back to the previous menu in the stack"""
	# Play back sound
	if AudioManager:
		AudioManager.play_ui_sound("ui_back")
	
	if menu_stack.size() <= 1:
		# No previous menu, close current
		close_current_menu()
		return
	
	# Remove current menu from stack
	menu_stack.pop_back()
	
	# Get previous menu
	var previous_menu = menu_stack.back() if menu_stack.size() > 0 else ""
	
	if previous_menu.is_empty():
		close_current_menu()
	else:
		open_menu(previous_menu, true)
	
	menu_stack_changed.emit(menu_stack.size())

func close_all_menus(use_transition: bool = false) -> void:
	"""Close all menus and clear the stack"""
	if use_transition and not current_menu.is_empty():
		await close_current_menu(true)
	
	# Close any remaining menus immediately
	for menu_name in menu_stack:
		var menu_instance = menu_instances.get(menu_name)
		if menu_instance and menu_instance.has_method("close_menu"):
			menu_instance.close_menu(false)
	
	# Clear state
	menu_stack.clear()
	current_menu = ""
	menu_stack_changed.emit(0)
	
	# Resume game
	if game_tree:
		game_tree.paused = false
	
	if OS.is_debug_build():
		print("MenuManager: All menus closed")

# Input handling

func _unhandled_input(event: InputEvent) -> void:
	if not current_menu.is_empty() and event.is_action_pressed("ui_cancel"):
		go_back()
		get_viewport().set_input_as_handled()

# Private Helper Methods

func _get_or_load_menu(menu_name: String) -> Node:
	"""Get existing menu instance or load new one"""
	# Check if already loaded
	if menu_instances.has(menu_name):
		return menu_instances[menu_name]
	
	# Try to load from scene path
	var scene_path = menu_scene_paths.get(menu_name, "")
	if scene_path.is_empty():
		print("ERROR: No scene path registered for menu: ", menu_name)
		return null
	
	var menu_scene = load(scene_path)
	if not menu_scene:
		print("ERROR: Could not load menu scene: ", scene_path)
		return null
	
	var menu_instance = menu_scene.instantiate()
	if not menu_instance:
		print("ERROR: Could not instantiate menu: ", menu_name)
		return null
	
	# Add to scene tree
	get_tree().root.add_child(menu_instance)
	
	# Register the instance
	register_menu(menu_name, menu_instance)
	
	return menu_instance

func _switch_to_menu(menu_name: String, previous_menu: String) -> void:
	"""Switch from current menu to target menu"""
	# Close previous menu if it exists
	if not previous_menu.is_empty():
		var prev_instance = menu_instances.get(previous_menu)
		if prev_instance and prev_instance.has_method("close_menu"):
			prev_instance.close_menu(false)  # No animation during transition
	
	# Open new menu
	var menu_instance = menu_instances.get(menu_name)
	if menu_instance and menu_instance.has_method("open_menu"):
		menu_instance.open_menu(false)  # No animation during transition
	elif menu_instance is CanvasLayer:
		menu_instance.visible = true
	
	# Update stack and current menu
	if not previous_menu.is_empty() and previous_menu != menu_name:
		if previous_menu not in menu_stack:
			menu_stack.append(previous_menu)
	
	if menu_name not in menu_stack:
		menu_stack.append(menu_name)
	
	current_menu = menu_name
	
	# Update layers
	_update_menu_layers()
	
	# Emit signal
	menu_opened.emit(menu_name)
	menu_stack_changed.emit(menu_stack.size())

func _close_menu_immediate(menu_name: String) -> void:
	"""Immediately close a menu without animation"""
	var menu_instance = menu_instances.get(menu_name)
	if not menu_instance:
		return
	
	# Close the menu
	if menu_instance.has_method("close_menu"):
		menu_instance.close_menu(false)
	elif menu_instance is CanvasLayer:
		menu_instance.visible = false
	
	# Remove from stack
	if menu_name in menu_stack:
		menu_stack.erase(menu_name)
	
	# Update current menu
	if current_menu == menu_name:
		current_menu = menu_stack.back() if menu_stack.size() > 0 else ""
	
	# Emit signals
	menu_closed.emit(menu_name)
	menu_stack_changed.emit(menu_stack.size())

func _update_menu_layers() -> void:
	"""Update menu layers based on stack order"""
	for i in range(menu_stack.size()):
		var menu_name = menu_stack[i]
		var menu_instance = menu_instances.get(menu_name)
		
		if menu_instance is CanvasLayer:
			menu_instance.layer = MENU_LAYER_BASE + (i * MENU_LAYER_INCREMENT)

func _connect_menu_signals(menu_name: String, menu_node: Node) -> void:
	"""Connect signals from a menu instance"""
	# Connect BaseMenu signals if available
	if menu_node.has_signal("menu_navigation_requested"):
		menu_node.menu_navigation_requested.connect(_on_menu_navigation_requested.bind(menu_name))
	
	if menu_node.has_signal("menu_closed"):
		menu_node.menu_closed.connect(_on_menu_closed)
	
	if menu_node.has_signal("menu_opened"):
		menu_node.menu_opened.connect(_on_menu_opened)

# Signal Callbacks

func _on_menu_navigation_requested(requesting_menu: String, from_menu: String, to_menu: String) -> void:
	"""Handle menu navigation requests"""
	if OS.is_debug_build():
		print("MenuManager: Navigation requested from ", from_menu, " to ", to_menu)
	
	open_menu(to_menu, true)

func _on_menu_opened(menu_name: String) -> void:
	"""Handle menu opened signal"""
	menu_opened.emit(menu_name)

func _on_menu_closed(menu_name: String) -> void:
	"""Handle menu closed signal"""
	menu_closed.emit(menu_name)

func _on_transition_completed() -> void:
	"""Handle fade transition completion"""
	if OS.is_debug_build():
		print("MenuManager: Fade transition completed")

func _on_fade_in_completed() -> void:
	"""Handle fade in completion"""
	if OS.is_debug_build():
		print("MenuManager: Fade in completed")

func _on_scene_changed(scene_name: String) -> void:
	"""Handle scene change events"""
	# Close all menus when scene changes
	close_all_menus(false)

# Utility Methods

func get_current_menu() -> String:
	"""Get the name of the currently active menu"""
	return current_menu

func get_menu_stack() -> Array[String]:
	"""Get a copy of the current menu stack"""
	return menu_stack.duplicate()

func has_menu(menu_name: String) -> bool:
	"""Check if a menu is registered"""
	return menu_instances.has(menu_name)

func is_menu_open(menu_name: String) -> bool:
	"""Check if a specific menu is currently open"""
	return current_menu == menu_name

func get_menu_instance(menu_name: String) -> Node:
	"""Get a menu instance by name"""
	return menu_instances.get(menu_name)

func register_menu_scene_path(menu_name: String, scene_path: String) -> void:
	"""Register a scene path for lazy loading"""
	menu_scene_paths[menu_name] = scene_path
	
	if OS.is_debug_build():
		print("MenuManager: Scene path registered for ", menu_name, ": ", scene_path)

# Debug Methods

func debug_print_state() -> void:
	"""Print current state for debugging"""
	if OS.is_debug_build():
		print("=== MenuManager State ===")
		print("Current Menu: ", current_menu)
		print("Menu Stack: ", menu_stack)
		print("Registered Menus: ", menu_instances.keys())
		print("Is Transitioning: ", is_transitioning)
		print("========================")

func get_debug_info() -> Dictionary:
	"""Get debug information as dictionary"""
	return {
		"current_menu": current_menu,
		"menu_stack": menu_stack.duplicate(),
		"registered_menus": menu_instances.keys(),
		"is_transitioning": is_transitioning,
		"fade_transition_available": fade_transition != null,
		"menu_scene_paths": menu_scene_paths.duplicate()
	}