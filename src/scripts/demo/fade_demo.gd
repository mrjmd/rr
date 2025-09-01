extends Control
## Interactive demo showing working fade transitions with visual buttons

@onready var fade_transition: FadeTransition
@onready var status_label: Label = $VBoxContainer/Status
@onready var show_button: Button = $VBoxContainer/ShowOverlayButton
@onready var hide_button: Button = $VBoxContainer/HideOverlayButton
@onready var fade_in_button: Button = $VBoxContainer/FadeInButton
@onready var fade_out_button: Button = $VBoxContainer/FadeOutButton
@onready var full_button: Button = $VBoxContainer/FullTransitionButton

func _ready() -> void:
	print("=== FADE DEMO STARTED ===")
	
	# Load and add the fade transition
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	fade_transition = fade_scene.instantiate()
	
	# IMPORTANT: Set fade to lower layer so UI stays on top
	fade_transition.layer = 100  # Lower than default 1000
	
	get_tree().root.add_child.call_deferred(fade_transition)
	
	# Put our UI on a higher canvas layer to stay above fade
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 200  # Higher than fade's 100
	get_parent().remove_child(self)
	canvas_layer.add_child(self)
	get_tree().root.add_child(canvas_layer)
	
	# Wait for setup
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Connect button signals
	show_button.pressed.connect(_on_show_overlay)
	hide_button.pressed.connect(_on_hide_overlay)
	fade_in_button.pressed.connect(_on_fade_in)
	fade_out_button.pressed.connect(_on_fade_out)
	full_button.pressed.connect(_on_full_transition)
	
	# Connect fade transition signals for status updates
	fade_transition.fade_in_completed.connect(_on_fade_in_completed)
	fade_transition.fade_out_completed.connect(_on_fade_out_completed)
	fade_transition.transition_completed.connect(_on_transition_completed)
	
	status_label.text = "Ready - Click buttons or use keys: [SPACE]=Toggle [F]=Fade In [G]=Fade Out"
	print("Fade demo initialized successfully")
	print("Keyboard shortcuts: SPACE=Toggle Overlay, F=Fade In, G=Fade Out")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				# Toggle overlay
				if fade_transition.color_rect.modulate.a > 0.5:
					_on_hide_overlay()
				else:
					_on_show_overlay()
			KEY_F:
				_on_fade_in()
			KEY_G:
				_on_fade_out()
			KEY_T:
				_on_full_transition()

func _on_show_overlay() -> void:
	status_label.text = "Showing black overlay..."
	fade_transition.show_overlay()
	await get_tree().process_frame
	status_label.text = "Black overlay shown - should cover green background"

func _on_hide_overlay() -> void:
	status_label.text = "Hiding black overlay..."
	fade_transition.hide_overlay()
	await get_tree().process_frame
	status_label.text = "Overlay hidden - green background should be visible"

func _on_fade_in() -> void:
	if fade_transition.is_transitioning():
		status_label.text = "Already transitioning - wait..."
		return
		
	status_label.text = "Fading in to black..."
	_disable_buttons()
	fade_transition.fade_in()

func _on_fade_out() -> void:
	if fade_transition.is_transitioning():
		status_label.text = "Already transitioning - wait..."
		return
		
	status_label.text = "Fading out from black..."
	_disable_buttons()
	fade_transition.fade_out()

func _on_full_transition() -> void:
	if fade_transition.is_transitioning():
		status_label.text = "Already transitioning - wait..."
		return
		
	status_label.text = "Starting full transition (fade in + fade out)..."
	_disable_buttons()
	fade_transition.transition()

func _on_fade_in_completed() -> void:
	status_label.text = "Fade in completed - screen should be black"
	_enable_buttons()

func _on_fade_out_completed() -> void:
	status_label.text = "Fade out completed - green background visible"
	_enable_buttons()

func _on_transition_completed() -> void:
	status_label.text = "Full transition completed - back to normal view"
	_enable_buttons()

func _disable_buttons() -> void:
	show_button.disabled = true
	hide_button.disabled = true
	fade_in_button.disabled = true
	fade_out_button.disabled = true
	full_button.disabled = true

func _enable_buttons() -> void:
	show_button.disabled = false
	hide_button.disabled = false
	fade_in_button.disabled = false
	fade_out_button.disabled = false
	full_button.disabled = false