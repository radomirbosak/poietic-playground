class_name IssueIndicator extends Node2D

var width: float = 48
var icon: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	icon = Sprite2D.new()
	icon.texture = load("res://resources/icons/error.png")
	var size = icon.texture.get_size()
	var scale = width / size.x
	icon.scale = Vector2(scale, scale)
	icon.position.y -= 3
	icon.z_index = DiagramCanvas.issues_indicator_z_index + 1
	add_child(icon)	

func get_rect() -> Rect2:
	return icon.get_rect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
