extends Node2D

# var sprite: Sprite2D
@onready var label = $Label
@onready var sprite = $Sprite
@onready var outline = $Outline
var shape: Shape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = "node"
	label.add_theme_color_override("font_color", Color.GREEN)
	
	print("Node position :", self.position)
	print("Label position:", label.position)
	shape = CircleShape2D.new()
	shape.radius = 48
	
	
func _draw():
	draw_circle(Vector2(0, 0), shape.radius, Color.GREEN, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func has_point(point: Vector2):
	var local_point = to_local(point)
	if shape is RectangleShape2D:
		return shape.get_rect().has_point(local_point)
	elif shape is CircleShape2D:
		return local_point.distance_to(Vector2.ZERO) <= shape.radius
	else:
		push_error("Shapes other than rect or circle are not supported")
		return false
