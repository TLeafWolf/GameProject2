extends CanvasLayer

@onready var button = $Button
@onready var panel = $Panel
@onready var player := get_tree().get_first_node_in_group("player")

func _ready():
	# show cutscene at the start
	panel.visible = true
	button.visible = true
	button.pressed.connect(_on_button_pressed)
	
	#disable player movement
	#if player:
		#player.can_move = false
		
func _on_button_pressed():
	#hide cutscene when button is pressed
	panel.visible = false
	button.visible = false
	visible = false
	# enadbel playe rmovement
	if player:
		player.can_move = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
