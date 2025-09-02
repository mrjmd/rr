extends Label

var player: Node2D = null

func _ready() -> void:
	print("Feedback Display initialized")
	# Add to group for frustration meter
	add_to_group("feedback_displays")
	
	# Find the player to get feedback from
	await get_tree().process_frame  # Wait for all nodes to be ready
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
		print("✅ Connected to player for feedback display")
	else:
		print("❌ No player found for feedback display")

func _process(delta: float) -> void:
	if player and player.has_method("get_current_feedback"):
		var feedback = player.get_current_feedback()
		text = feedback
		
		# Style the feedback based on content
		if feedback == "":
			modulate = Color.TRANSPARENT
		elif "Need both hands" in feedback:
			modulate = Color.YELLOW
		elif "Making coffee" in feedback or "brewing" in feedback:
			modulate = Color.CYAN
		elif "ready" in feedback or "won" in feedback:
			modulate = Color.GREEN
		else:
			modulate = Color.WHITE

func show_message(message: String) -> void:
	"""Show a temporary message in the feedback display"""
	if player and player.has_method("show_feedback"):
		player.show_feedback(message)