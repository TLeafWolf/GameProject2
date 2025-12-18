extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var yaw := 0.0   # horizontal rotation
var pitch := 0.0 # vertical rotation
var can_move: bool = true
var can_attack: bool = true

@onready var hud := get_tree().get_first_node_in_group("UI")
@onready var camera = $Camera3D
# Health variables
@export var max_health: int = 50 # Max health
@export var mouse_sensitivity: float = 0.1
var health: int = 50  # Current health

func _ready():
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	print("HUD node found:", hud)
	if hud:
		hud.call_deferred("update_health", health, max_health)
		print("ERROR: HUD node not found! Make sure it exists and is in group 'UI'.")

func _process(_delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -90, 90)  # prevent flipping upside down

		# Rotate player horizontally (yaw)
		rotation_degrees.y = yaw

		# Rotate camera vertically (pitch)
		$Camera3D.rotation_degrees.x = pitch
	if Input.is_action_just_pressed("cancel_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction and move player
	var forward = -transform.basis.z
	var right = transform.basis.x
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		input_dir += forward
	if Input.is_action_pressed("back"):
		input_dir -= forward
	if Input.is_action_pressed("right"):
		input_dir += right
	if Input.is_action_pressed("left"):
		input_dir -= right
	if Input.is_action_just_pressed("attack"):
		attack()

	input_dir = input_dir.normalized()
	velocity.x = input_dir.x * SPEED
	velocity.z = input_dir.z * SPEED

	move_and_slide()

# dammage receive
func take_damage(amount: int):
	health -= amount
	health = max(health, 0)
	if hud:
		hud.update_health(health, max_health)
	if health == 0:
		game_over()

# empty game over till we get something to display on game over
func game_over():
	if GameState.old_man_state == 1:
		GameState.player_died_after_quest = true
	# Simple respawn
	#health = max_health
	#global_position = Vector3.ZERO
	#hud.update_health(health, max_health)
	
	#game over screene
	var game_over_screen = get_tree().current_scene.get_node("GameOverScreen") 
	if game_over_screen and game_over_screen.has_method("show_game_over"):
		game_over_screen.show_game_over()

func attack():
	if can_attack:
		can_attack = false
		$AttackTimer.start()
		$Cane/AnimationPlayer.play("Attack")
		for body in $Area3D.get_overlapping_bodies():
			if body.is_in_group("enemy"):
				body.hurt()

func _on_attack_timer_timeout() -> void:
	can_attack = true
