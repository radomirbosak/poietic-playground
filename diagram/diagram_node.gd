class_name DiagramNode extends Node2D

var is_selected: bool = false
var selection_highlight: Node2D = null

# var sprite: Sprite2D
var label: Label # = $Label
var shape: Shape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	label = Label.new()
	self.add_child(label)
	self.label.text = "node"
	label.add_theme_color_override("font_color", Color.GREEN)
	
	shape = CircleShape2D.new()
	shape.radius = 48
	update_children()

func bounding_circle_radius() -> float:
	return shape.radius
	
func update_children():
	var size = label.get_minimum_size()
	label.position = -size * 0.5
	
func _draw():
	draw_circle(Vector2(0, 0), shape.radius, Color.GREEN, false)
	if is_selected:
		draw_circle(Vector2(0, 0), shape.radius + 4, Color.WHITE, false, 2)

func set_selected(flag: bool):
	self.is_selected = flag
	queue_redraw()
		
func has_point(point: Vector2):
	var local_point = to_local(point)
	if shape is RectangleShape2D:
		return shape.get_rect().has_point(local_point)
	elif shape is CircleShape2D:
		return local_point.distance_to(Vector2.ZERO) <= shape.radius
	else:
		push_error("Shapes other than rect or circle are not supported")
		return false
