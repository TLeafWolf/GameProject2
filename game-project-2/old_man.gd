extends Node3D


var player: Node3D = null

@onready var interact_area = $Area3D
@onready var label = $Label3D

var player_in_range := false
var dialogue_index := -1
var dialogue_lines: Array = []

enum NPCState { INTRO, QUEST_GIVEN, PLAYER_DIED, CANE_GIVEN }

@export var prompt_text := "Press E to talk"

@export var intro_dialogue := [
	"Oh, hello traveler!",
	"I know we just met but I must ask you a favor.",
    "I lost my glasses, could you bring them back to me? They're just up ahead."
]

@export var after_death_dialogue := [
	"Back already?",
	"I would've thought you brought something.",
    "Fine. Take my cane and this... uh... lid."
]

@export var quest_reminder := ["Hurry up. Those glasses are important."]
@export var cane_dialogue := ["Don't lose that cane."]

func _ready():
	label.text = ""
	label.visible = false



func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("Interact"):
		interact()
	if player_in_range and player:
		var target_pos = player.global_position
		var my_pos = global_position

		target_pos.y = my_pos.y  # keep rotation horizontal only
		look_at(target_pos, Vector3.UP)
		rotation.y += deg_to_rad(90) # keep your fix

func interact():
	# Start dialogue
	dialogue_index += 1

	if dialogue_index < dialogue_lines.size():
		label.text = dialogue_lines[dialogue_index]
		return

	# Dialogue finished
	dialogue_index = -1

	# Update NPC state
	match GameState.old_man_state:
		NPCState.INTRO:
			GameState.old_man_state = NPCState.QUEST_GIVEN
		NPCState.QUEST_GIVEN:
			if GameState.player_died_after_quest:
				# give_player_cane_and_shield()
				GameState.old_man_state = NPCState.CANE_GIVEN
				GameState.player_died_after_quest = false

	# Show prompt again
	label.text = prompt_text

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Body entered:", body.name)
	if body.is_in_group("player"):
		player = body
		player_in_range = true
		dialogue_index = -1

		# Select dialogue lines based on state
		match GameState.old_man_state:
			NPCState.INTRO:
				dialogue_lines = intro_dialogue
			NPCState.QUEST_GIVEN:
				if GameState.player_died_after_quest:
					dialogue_lines = after_death_dialogue
				else:
					dialogue_lines = quest_reminder
			NPCState.CANE_GIVEN:
				dialogue_lines = cane_dialogue

		# Only show prompt if not mid-dialogue
		label.text = prompt_text
		label.visible = true
		print("Player entered interaction area!")  # Debug

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = null
		player_in_range = false
		dialogue_index = -1
		label.visible = false
		print("Player left interaction area!")  # Debug
