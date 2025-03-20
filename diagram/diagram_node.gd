class_name DiagramNode extends Node2D
# Physics: extends RigidBody2D

const _DEBUG = false
const label_offset = 10
const default_radius = 50
const highlight_padding = 5

## Value to be displayed using a value indicator.
##
## Typically a computed simulation value of the node.
##
var display_value: Variant = 0.0:
	set(value):
		if value is float or value == null:
			display_value = value
			update_indicator()
		else:
			push_warning("Invalid display value for node ID ", object_id, ": ", value)

var object_id: int = 0

# Node Components (Children)
var image: Sprite2D
var shape: Shape2D
var label_text: Label
var value_indicator: ValueIndicator
# TODO: Physics
var collision: CollisionShape2D = CollisionShape2D.new()

@export var type_name: String = "unknown":
	set(value):
		type_name = value
		queue_layout()
		
@export var label: String = "(node)":
	set(value):
		label = value
		queue_layout()

# Select Tool
var touchable_outline: PackedVector2Array = []
var is_selected: bool = false:
	set(value):
		is_selected = value
		queue_redraw()
		
var has_errors: bool = false:
	set(value):
		has_errors = value
		if error_indicator:
			error_indicator.visible = has_errors

var is_dragged: bool = false
var selection_highlight_shape: Shape2D = null
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

# Called when the node enters the scene tree for the first time.
func _ready():
	# add_child(collision)
	update_children()

var last_position: Vector2 = Vector2()
var is_moved: bool
var children_needs_update: bool = true

func _draw():
	if shape and _DEBUG:
		DiagramGeometry.draw_shape(self, shape, Color.HOT_PINK)
	if is_selected and selection_highlight_shape:
		DiagramGeometry.draw_shape(self, selection_highlight_shape, DiagramCanvas.default_selection_color, 2)
		
func _process(_delta):
	if position != last_position:
		last_position = position
		is_moved = true
	if children_needs_update:
		update_children()
		children_needs_update = false
	value_indicator.visible = Global.show_value_indicators

func queue_layout():
	children_needs_update = true

func set_moved():
	is_moved = false

var force_strength = 1000

func _physics_process(_delta: float) -> void:
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

## Updates the diagram node based on a design object.
##
## This method should be called whenever the source of truth is changed.
func update_from(object: PoieticObject):
	var position = object.get_position()
	if position is Vector2:
		self.position = position

	self.label = object.name
	queue_layout()

func update_children() -> void:
	update_pictogram()
	update_indicator()
	if label_text == null:
		label_text = Label.new()
		self.add_child(label_text)
		label_text.add_theme_color_override("font_color", DiagramCanvas.default_label_color)

	var shape_rect = shape.get_rect()

	if label == null:
		label_text.text = ""
	else:
		label_text.text = label
		label_text.queue_redraw()
	var label_size = label_text.get_minimum_size()
	label_text.position = Vector2(-label_size.x * 0.5, shape_rect.size.y / 2 + label_offset)
	children_needs_update = false
	
	if error_indicator == null:
		var height: float = (sqrt(3.0) / 2.0) * error_indicator_size
		error_indicator = Polygon2D.new()
		var polygon: PackedVector2Array = [
			Vector2(-error_indicator_size, -height),
			Vector2(+error_indicator_size, -height),
			Vector2(0, height),
			Vector2(-error_indicator_size, -height),
		]
		error_indicator.polygon = polygon
		error_indicator.color = Color.RED
		error_indicator.position = Vector2(0, -shape_rect.size.y/2) + error_indicator_offset
		error_indicator.visible = false
		self.add_child(error_indicator)
		# 	var polygons = Geometry2D.offset_polyline([arrow_origin, arrow_target], 10, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)

var error_indicator_size: float = 10.0
var error_indicator: Polygon2D
var error_indicator_offset: Vector2 = Vector2(0, -10)

func update_pictogram():
	if image == null:
		image = Sprite2D.new()
		add_child(image)

	var pictogram: Pictogram = Pictogram.get_pictogram(type_name)
	image.texture = ImageTexture.create_from_image(pictogram.get_image())
	shape = pictogram.shape
	# TODO: Use offset shape, not grow shape.
	selection_highlight_shape = DiagramGeometry.offset_shape(shape, 6)
	# collision.shape = shape

var indicator_offset = 30

func update_indicator():
	if value_indicator == null:
		var indicator = ValueIndicator.new()
		indicator.position = Vector2(0, - shape.get_rect().size.y / 2 - indicator_offset)
		indicator.min_value = 0
		indicator.max_value = 100
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color.YELLOW
		fill_style.border_color = Color.LIME_GREEN
		fill_style.set_border_width_all(0)
		indicator.normal_style = fill_style
		var bg_style = StyleBoxFlat.new()
		bg_style.bg_color = Color.BLACK
		bg_style.border_color = Color.DIM_GRAY
		bg_style.set_border_width_all(2)
		indicator.bg_style = bg_style
		add_child(indicator)
		value_indicator = indicator
		
	# TODO: Make indicator display some "unknown status" when the value is null
	if self.display_value: 
		value_indicator.value = self.display_value
	else:
		# push_warning("No display value")
		value_indicator.value = null

func bounding_radius():
	if shape is RectangleShape2D:
		var rect = shape.get_rect()
		return Vector2(rect.size.x / 2, rect.size.y / 2).length()
	elif shape is CircleShape2D:
		return shape.radius
	else:
		push_error("Shapes other than rect or circle are not supported")
		return false

func set_selected(flag: bool):
	self.is_selected = flag
	queue_redraw()
		
func contains_point(point: Vector2):
	var local_point = to_local(point)
	
	var touch_shape: Shape2D = CircleShape2D.new()
	touch_shape.radius = 10
	var collision_trans = self.transform.translated(local_point)

	return shape.collide(self.transform, touch_shape, collision_trans)
