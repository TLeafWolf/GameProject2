extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Health variables
@export var max_health: int = 50 # Max health
var health: int = 50  # Current health

# 3D Label
@onready var health_label: Label3D = $HealthLabel  # Assuming your 3D Label is named "HealthLabel"

func _ready():
	# Initialize the health text
	health_label.text = "Health: %d/%d" % [health, max_health]

func _process(delta):
	# Only update health display
	health_label.text = "Health: %d/%d" % [health, max_health]

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction and move player
	var input_dir := Input.get_vector("left", "right", "foward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# dammage receive
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		game_over()
	update_health_ui()
	
# empty game over till we get something to display on game over
func game_over():
	var game_over_screen = get_tree().current_scene.get_node("GameOverScreen") 
	if game_over_screen and game_over_screen.has_method("show_game_over"):
		game_over_screen.show_game_over()
# Function to update the text in the label
func update_health_ui():
	health_label.text = "Health: %d/%d" % [health, max_health]
