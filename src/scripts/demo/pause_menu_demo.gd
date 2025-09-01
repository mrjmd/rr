extends Control
## Demo scene for testing the pause menu functionality

# UI references
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var instructions_label: Label = $CenterContainer/VBoxContainer/InstructionsLabel
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var pause_menu = $PauseMenu

# Demo state
var demo_timer: float = 0.0
var is_demo_running: bool = true

func _ready() -> void:
	# Setup UI
	_setup_demo_ui()
	
	# Connect to pause menu events
	_connect_pause_menu_signals()
	
	if OS.is_debug_build():
		print("PauseMenuDemo initialized")

func _setup_demo_ui() -> void:
	"""Configure the demo UI elements"""
	if title_label:
		title_label.add_theme_font_size_override("font_size", 32)
		title_label.add_theme_color_override("font_color", Color.WHITE)
	
	if instructions_label:
		instructions_label.add_theme_font_size_override("font_size", 16)
		instructions_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	
	if status_label:
		status_label.add_theme_font_size_override("font_size", 20)
		status_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))

func _connect_pause_menu_signals() -> void:
	"""Connect to pause menu signals"""
	# SimplePauseMenu doesn't have these signals, so we'll monitor state differently
	
	# Connect to EventBus pause events only if EventBus is available
	var event_bus: Node = get_node_or_null("/root/EventBus")
	if event_bus:
		if event_bus.has_signal("game_paused"):
			event_bus.game_paused.connect(_on_game_paused)
		if event_bus.has_signal("game_resumed"):
			event_bus.game_resumed.connect(_on_game_resumed)
	else:
		if OS.is_debug_build():
			print("EventBus not available - running in standalone mode")

func _process(delta: float) -> void:
	"""Update demo timer and status"""
	if is_demo_running and not get_tree().paused:
		demo_timer += delta
		_update_status_display()

func _update_status_display() -> void:
	"""Update the status label with current information"""
	if not status_label:
		return
	
	var status_text = ""
	
	if get_tree().paused:
		if pause_menu and pause_menu.is_open():
			status_text = "PAUSED (Menu Open) - Timer: %.2f s" % demo_timer
		else:
			status_text = "PAUSED (External) - Timer: %.2f s" % demo_timer
	else:
		status_text = "Game Running - Timer: %.2f s" % demo_timer
	
	status_label.text = status_text

func _input(event: InputEvent) -> void:
	"""Handle demo-specific input"""
	# Show debug info
	if event.is_action_pressed("debug_toggle") and OS.is_debug_build():
		_print_debug_info()

func _print_debug_info() -> void:
	"""Print current demo and pause menu state"""
	if not OS.is_debug_build():
		return
	
	print("=== Pause Menu Demo Debug Info ===")
	print("Demo Timer: %.2f", demo_timer)
	print("Tree Paused: ", get_tree().paused)
	print("Demo Running: ", is_demo_running)
	
	if pause_menu:
		print("Pause Menu State: ", pause_menu.get_pause_menu_debug_info())
	else:
		print("Pause Menu: Not found!")
	
	print("=== End Debug Info ===")

# Signal Callbacks

func _on_pause_menu_opened(menu_name: String) -> void:
	"""Handle when pause menu is opened"""
	if OS.is_debug_build():
		print("Demo: Pause menu opened - ", menu_name)
	
	is_demo_running = false
	_update_status_display()

func _on_pause_menu_closed(menu_name: String) -> void:
	"""Handle when pause menu is closed"""
	if OS.is_debug_build():
		print("Demo: Pause menu closed - ", menu_name)
	
	is_demo_running = true
	_update_status_display()

func _on_pause_menu_button_pressed(button_name: String) -> void:
	"""Handle pause menu button presses"""
	if OS.is_debug_build():
		print("Demo: Pause menu button pressed - ", button_name)

func _on_game_paused() -> void:
	"""Handle game pause event"""
	if OS.is_debug_build():
		print("Demo: Game paused via EventBus")
	_update_status_display()

func _on_game_resumed() -> void:
	"""Handle game resume event"""
	if OS.is_debug_build():
		print("Demo: Game resumed via EventBus")
	_update_status_display()

# Public API for testing

func reset_demo() -> void:
	"""Reset the demo to initial state"""
	demo_timer = 0.0
	is_demo_running = true
	
	# Close pause menu if open
	if pause_menu and pause_menu.is_open():
		pause_menu.hide_menu()
	
	_update_status_display()

func get_demo_state() -> Dictionary:
	"""Get current demo state for testing"""
	return {
		"timer": demo_timer,
		"is_running": is_demo_running,
		"tree_paused": get_tree().paused,
		"pause_menu_open": pause_menu.is_open() if pause_menu else false
	}