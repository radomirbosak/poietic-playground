class_name DiagramNode extends Node2D
# Physics: extends RigidBody2D

const default_radius = 50
const highlight_padding = 5

# Node Components (Children)
var pictogram: Node2D
var shape: Shape2D
var label_text: Label

# TODO: Physics
var collision: CollisionShape2D = CollisionShape2D.new()

@export var type_name: String = "unknown":
	set(value):
		type_name = value
		update_children()
		
@export var label: String = "(node)":
	set(value):
		label = value
		update_children()

# Select Tool
var touchable_outline: PackedVector2Array = []
var is_selected: bool = false:
	set(value):
		is_selected = value
		update_highlight()
		
var is_dragged: bool = false
var selection_highlight: Node2D = null
var target_position: Vector2 = Vector2():
	set(value):
		# TODO: Remove this for Physics
		self.position = target_position

func _init():
	# TODO: Physics
	# lock_rotation = true
	# gravity_scale = 0.0
	# mass = 1.0
	# linear_damp = 4.0
	
	shape = CircleShape2D.new()
	shape.radius = default_radius

	selection_highlight = Node2D.new()
	selection_highlight.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	# add_child(collision)
	update_children()
	

var last_position: Vector2 = Vector2()
var is_moved: bool

func _process(_delta):
	if position != last_position:
		last_position = position
		is_moved = true

func set_moved():
	is_moved = false

var force_strength = 1000

func _physics_process(delta: float) -> void:
	pass
	# TODO: Physics
	#if is_dragged:
		#if freeze:
			#global_position = target_position
		#else:
			#var direction = (target_position - global_position)
			#apply_central_force(direction*10)

func bounding_circle_radius() -> float:
	return shape.radius
	
func update_children() -> void:
	update_pictogram()
	if label_text == null:
		label_text = Label.new()
		self.add_child(label_text)
		label_text.add_theme_color_override("font_color", DiagramCanvas.default_label_color)

	if label == null:
		label_text.text = ""
	else:
		label_text.text = label
		label_text.queue_redraw()
	var size = label_text.get_minimum_size()
	label_text.position = -size * 0.5
	update_highlight()

func update_pictogram():
	if pictogram != null:
		pictogram.free()
	match type_name:
		"stock":
			var rect = ShapeCreator.rectangle_with_center(Vector2(), default_radius * 3, default_radius * 2)
			var path = Line2D.new()
			for point in ShapeCreator.rectangle_to_polygon(rect):
				path.add_point(point)
			pictogram = path
			path.width = 2
			path.default_color = DiagramCanvas.default_pictogram_color
			shape = RectangleShape2D.new()
			shape.size = Vector2(default_radius*3, default_radius*2)
			add_child(pictogram)
		"flow":
			pictogram = Circle2D.new()
			pictogram.radius = default_radius
			pictogram.color = DiagramCanvas.default_pictogram_color
			shape = CircleShape2D.new()
			shape.radius = default_radius
			add_child(pictogram)
		_:
			pictogram = Circle2D.new()
			pictogram.radius = default_radius
			pictogram.color = Color.RED
			shape = CircleShape2D.new()
			shape.radius = default_radius
			add_child(pictogram)
	# collision.shape = shape

func bounding_radius():
	if shape is RectangleShape2D:
		var rect = shape.get_rect()
		return Vector2(rect.size.x / 2, rect.size.y / 2).length()
	elif shape is CircleShape2D:
		return shape.radius
	else:
		push_error("Shapes other than rect or circle are not supported")
		return false

func update_highlight():
	if selection_highlight != null:
		selection_highlight.free()
		
	if shape is RectangleShape2D:
		var hlight = Line2D.new()
		for point in ShapeCreator.rectangle_to_polygon(shape.get_rect().grow(highlight_padding)):
			hlight.add_point(point)
		hlight.width = 2
		hlight.default_color = DiagramCanvas.default_selection_color
		add_child(hlight)
		selection_highlight = hlight
	elif shape is CircleShape2D:
		var hlight = Circle2D.new()
		hlight.radius = shape.radius + highlight_padding
		hlight.color = DiagramCanvas.default_selection_color
		add_child(hlight)
		selection_highlight = hlight
	else:
		var hlight = Line2D.new()
		for point in ShapeCreator.rectangle_to_polygon(shape.get_rect().grow(highlight_padding)):
			hlight.add_point(point)
		hlight.width = 2
		hlight.default_color = Color.RED
		add_child(hlight)
		selection_highlight = hlight
	
	if is_selected:
		selection_highlight.show()
	else:
		selection_highlight.hide()
	
func set_selected(flag: bool):
	self.is_selected = flag
		
func contains_point(point: Vector2):
	var local_point = to_local(point)
	
	var touch_shape: Shape2D = CircleShape2D.new()
	touch_shape.radius = 10
	var collision_trans = self.transform.translated(local_point)

	return shape.collide(self.transform, touch_shape, collision_trans)
