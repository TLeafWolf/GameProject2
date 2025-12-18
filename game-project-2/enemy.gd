extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D =  null

const SPEED = 3.0
const STOP_DISTANCE = 0.1
var angry = false
func _ready():
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Player node not found! Check the path.")

func _physics_process(_delta: float) -> void:
	if !angry:
		return
	
	# rotate to player
	if player:
		var target_pos = player.global_position
		target_pos.y = global_position.y  # keep rotation horizontal only
		look_at(target_pos, Vector3.UP)
		 # Update navigation target
		nav.set_target_position(player.global_position)
	
	if nav.is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()
		_set_target()
		return
	var next_pos = nav.get_next_path_position()
	
	var offset = next_pos - global_position
	offset.y = 0.0
	
	var distance = offset.length()
	
	if distance < STOP_DISTANCE:
		global_position = next_pos
		velocity = Vector3.ZERO
	else:
		velocity = offset.normalized() * SPEED
	move_and_slide()
	_set_target()

func _set_target() -> void:
	nav.set_target_position(player.position)

func _on_attack_box_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$AttackTimer.start()

func _on_attack_box_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		$AttackTimer.stop()

func _on_attack_timer_timeout() -> void:
	$Goblin/AnimationPlayer.play("Cylinder_003Action")
	player.take_damage(5)

func _on_aggro_range_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		angry = true
