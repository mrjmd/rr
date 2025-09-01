class_name BaseMenu
extends CanvasLayer
## Base class for all menu systems with common functionality and proper layer management

# Constants
const MENU_LAYER: int = 200

# Signals
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)
signal menu_button_pressed(button_name: String)
signal menu_navigation_requested(from_menu: String, to_menu: String)

# Menu state
enum MenuState {
	CLOSED,
	OPENING,
	OPEN,
	CLOSING
}

# Public variables
var menu_name: String = ""
var current_state: MenuState = MenuState.CLOSED
var is_modal: bool = true  # Whether this menu blocks interaction with other elements

# Private variables
var _initial_focus_button: Button
var _previous_focus: Control
var _is_initialized: bool = false

# Animation settings
@export var fade_duration: float = 0.3
@export var scale_duration: float = 0.2
@export var initial_scale: Vector2 = Vector2(0.8, 0.8)

# Onready references - to be set by child classes
@onready var menu_container: Control
@onready var background_panel: Panel

func _ready() -> void:
	# Set proper layer for menus
	layer = MENU_LAYER
	
	# Set process modes for pause handling
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Initially hidden
	visible = false
	
	# Initialize the menu
	_initialize_menu()
	
	# Connect signals
	_connect_menu_signals()
	
	if OS.is_debug_build():
		print("BaseMenu initialized: ", menu_name, " on layer ", layer)

func _initialize_menu() -> void:
	"""Initialize menu - override in child classes"""
	# This is called after _ready but before showing
	# Child classes should override this to set up their specific UI
	_is_initialized = true
	
	# Set menu name if not already set
	if menu_name.is_empty():
		menu_name = get_script().resource_path.get_file().get_basename()

func _connect_menu_signals() -> void:
	"""Connect to EventBus signals"""
	# Connect to global pause/resume events
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)

# Public Menu API

func open_menu(animate: bool = true) -> void:
	"""Open the menu with optional animation"""
	if current_state != MenuState.CLOSED:
		return
	
	current_state = MenuState.OPENING
	visible = true
	
	# Store previous focus for restoration
	_store_previous_focus()
	
	# Pause game if modal
	if is_modal:
		get_tree().paused = true
	
	if animate:
		await _play_open_animation()
	
	current_state = MenuState.OPEN
	
	# Set initial focus
	_set_initial_focus()
	
	# Emit signals
	menu_opened.emit(menu_name)
	EventBus.game_paused.emit()
	
	if OS.is_debug_build():
		print("Menu opened: ", menu_name)

func close_menu(animate: bool = true) -> void:
	"""Close the menu with optional animation"""
	if current_state != MenuState.OPEN:
		return
	
	current_state = MenuState.CLOSING
	
	# Clear focus
	_restore_previous_focus()
	
	if animate:
		await _play_close_animation()
	
	visible = false
	current_state = MenuState.CLOSED
	
	# Resume game if modal
	if is_modal:
		get_tree().paused = false
	
	# Emit signals
	menu_closed.emit(menu_name)
	EventBus.game_resumed.emit()
	
	if OS.is_debug_build():
		print("Menu closed: ", menu_name)

func toggle_menu(animate: bool = true) -> void:
	"""Toggle menu open/closed state"""
	match current_state:
		MenuState.CLOSED:
			open_menu(animate)
		MenuState.OPEN:
			close_menu(animate)

func is_menu_open() -> bool:
	"""Check if menu is currently open"""
	return current_state == MenuState.OPEN

func is_menu_transitioning() -> bool:
	"""Check if menu is currently transitioning"""
	return current_state == MenuState.OPENING or current_state == MenuState.CLOSING

# Animation Methods

func _play_open_animation() -> void:
	"""Animate menu opening"""
	if not menu_container:
		return
	
	# Start with scaled down and transparent
	menu_container.scale = initial_scale
	menu_container.modulate = Color.TRANSPARENT
	
	# Create animation tween
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in
	tween.tween_property(menu_container, "modulate", Color.WHITE, fade_duration)
	
	# Scale up with easing
	tween.tween_property(menu_container, "scale", Vector2.ONE, scale_duration)
	tween.tween_callback(_on_open_animation_complete).set_delay(max(fade_duration, scale_duration))
	
	# Wait for animation
	await tween.finished

func _play_close_animation() -> void:
	"""Animate menu closing"""
	if not menu_container:
		return
	
	# Create animation tween
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(menu_container, "modulate", Color.TRANSPARENT, fade_duration)
	
	# Scale down with easing
	tween.tween_property(menu_container, "scale", initial_scale, scale_duration)
	tween.tween_callback(_on_close_animation_complete).set_delay(max(fade_duration, scale_duration))
	
	# Wait for animation
	await tween.finished

func _on_open_animation_complete() -> void:
	"""Called when open animation completes"""
	if OS.is_debug_build():
		print("Menu open animation complete: ", menu_name)

func _on_close_animation_complete() -> void:
	"""Called when close animation completes"""
	if OS.is_debug_build():
		print("Menu close animation complete: ", menu_name)

# Focus Management

func _store_previous_focus() -> void:
	"""Store the currently focused control"""
	var viewport = get_viewport()
	if viewport:
		_previous_focus = viewport.gui_get_focus_owner()

func _restore_previous_focus() -> void:
	"""Restore focus to previously focused control"""
	if _previous_focus and is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()
	_previous_focus = null

func _set_initial_focus() -> void:
	"""Set focus to the initial button"""
	if _initial_focus_button and is_instance_valid(_initial_focus_button):
		_initial_focus_button.grab_focus()

func set_initial_focus_button(button: Button) -> void:
	"""Set which button should receive focus when menu opens"""
	_initial_focus_button = button

# Input Handling

func _unhandled_input(event: InputEvent) -> void:
	if not is_menu_open():
		return
	
	# Handle escape key to close menu
	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()
	
	# Handle navigation keys
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		_handle_navigation_input(event)
	
	# Handle accept key
	elif event.is_action_pressed("ui_accept"):
		_handle_accept_input()

func _handle_navigation_input(event: InputEvent) -> void:
	"""Handle keyboard navigation within menu"""
	var focused = get_viewport().gui_get_focus_owner()
	if not focused:
		_set_initial_focus()
		return
	
	# Let the default UI navigation handle this
	# This method can be overridden for custom navigation logic

func _handle_accept_input() -> void:
	"""Handle accept key press"""
	var focused = get_viewport().gui_get_focus_owner()
	if focused is Button:
		focused.pressed.emit()

# Button Management

func add_menu_button(button: Button, button_name: String = "") -> void:
	"""Add a button to the menu and connect its signals"""
	if not button:
		return
	
	var final_button_name = button_name
	if final_button_name.is_empty():
		final_button_name = button.name
	
	# Connect button signal
	if not button.pressed.is_connected(_on_menu_button_pressed):
		button.pressed.connect(_on_menu_button_pressed.bind(final_button_name))
	
	# Set as initial focus if it's the first button
	if not _initial_focus_button:
		set_initial_focus_button(button)
	
	if OS.is_debug_build():
		print("Menu button added: ", final_button_name, " to menu: ", menu_name)

func _on_menu_button_pressed(button_name: String) -> void:
	"""Handle when any menu button is pressed"""
	menu_button_pressed.emit(button_name)
	
	if OS.is_debug_build():
		print("Menu button pressed: ", button_name, " in menu: ", menu_name)

# Menu Navigation

func navigate_to_menu(target_menu: String) -> void:
	"""Navigate to another menu"""
	menu_navigation_requested.emit(menu_name, target_menu)

# Scene Integration

func integrate_with_scene_manager() -> void:
	"""Connect to SceneManager for scene transitions"""
	# This can be overridden by child classes for specific integration
	pass

# Event Callbacks

func _on_game_paused() -> void:
	"""Handle game pause event"""
	# Override in child classes if needed
	pass

func _on_game_resumed() -> void:
	"""Handle game resume event"""
	# Override in child classes if needed
	pass

# Utility Methods

func get_menu_buttons() -> Array[Button]:
	"""Get all buttons in this menu"""
	var buttons: Array[Button] = []
	_collect_buttons_recursive(self, buttons)
	return buttons

func _collect_buttons_recursive(node: Node, buttons: Array[Button]) -> void:
	"""Recursively collect all buttons in the menu"""
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		_collect_buttons_recursive(child, buttons)

func set_menu_container(container: Control) -> void:
	"""Set the main menu container for animations"""
	menu_container = container

func set_background_panel(panel: Panel) -> void:
	"""Set the background panel for styling"""
	background_panel = panel

# Debug Methods

func get_menu_debug_info() -> Dictionary:
	"""Get debug information about the menu"""
	return {
		"menu_name": menu_name,
		"current_state": MenuState.keys()[current_state],
		"is_modal": is_modal,
		"layer": layer,
		"visible": visible,
		"is_initialized": _is_initialized,
		"button_count": get_menu_buttons().size(),
		"has_focus_button": _initial_focus_button != null
	}

func debug_print_menu_state() -> void:
	"""Print current menu state for debugging"""
	if OS.is_debug_build():
		print("BaseMenu Debug State: ", get_menu_debug_info())