extends CanvasLayer
@onready var button = $Button
@onready var panel = $Panel
# We access the player when showing the screen, not necessarily @onready

func _ready():
	# Ensure the screen is hidden at the start
	panel.visible = false
	button.visible = false
	visible = false

func show_game_over():
	# Show the game over screen and disable player movement
	panel.visible = true
	button.visible = true
	visible = true
	
	# Find the player node dynamically when the game over happens
	var player = get_tree().current_scene.get_node("player")
	if player:
		player.can_move = false
		player.set_physics_process(false) # Make sure physics stops
	
	if not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Restart the level
	get_tree().reload_current_scene()
