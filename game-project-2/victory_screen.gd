extends CanvasLayer

@onready var button = $Button
@onready var panel = $Panel
# We access the player when showing the screen, not necessarily @onready

func _ready():
	# Ensure the screen is hidden at the start
	panel.visible = false
	button.visible = false
	visible = false

func show_victory():
	# Show the victory screen and disable player movement
	panel.visible = true
	button.visible = true
	visible = true

	# Find the player node dynamically when the goal is reached
	var player = get_tree().current_scene.get_node("player")
	if player:
		player.can_move = false
		player.set_physics_process(false)  # Make sure physics stops
	
	# Connect the button press event if it's not already connected
	if not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Restart the level
	get_tree().reload_current_scene()
	GameState.weapons = false
	GameState.old_man_state = 0

func _on_goal_body_entered(body: Node3D) -> void:
	# Check if the player has entered the goal area
	if body.name == "player" and GameState.weapons:
		show_victory()
