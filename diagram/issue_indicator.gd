class_name IssueIndicator extends Node2D

var size: float = 48
var icon: Sprite2D
var icon_scale: float

# Called when the node enters the scene tree for the first time.
func _ready():
	icon = Sprite2D.new()
	icon.texture = load("res://resources/icons/error.png")
	var icon_size = icon.texture.get_size()
	icon_scale = size / icon_size.x
	icon.scale = Vector2(icon_scale, icon_scale)
	icon.position.y -= 3
	icon.z_index = DiagramCanvas.issues_indicator_z_index + 1
	add_child(icon)	

func get_rect() -> Rect2:
	return Rect2(-size / 2, -size / 2, size, size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
