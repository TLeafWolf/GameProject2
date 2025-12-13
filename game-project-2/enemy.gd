extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"

const SPEED = 3.0
const STOP_DISTANCE = 0.1

func _physics_process(delta: float) -> void:
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

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$AttackTimer.start()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		$AttackTimer.stop()

func _on_attack_timer_timeout() -> void:
	player.take_damage(5)
