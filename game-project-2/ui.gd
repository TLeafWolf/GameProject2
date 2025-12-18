extends CanvasLayer
@onready var health_label: Label = get_node("Control/health_label") as Label

func update_health(current: int, max_health_value: int):
	health_label.text = "Health: %d / %d" % [current, max_health_value]
func _ready():
	print("CanvasLayer children: ", get_children())
	print("Control node: ", get_node_or_null("Control"))
	print("HealthLabel node: ", get_node_or_null("Control/health_label"))
