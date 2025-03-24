class_name DiagramConnector extends DiagramObject
# TODO: Rename to DiagramConnector

var origin: DiagramNode
var target: DiagramNode

@export var connector: Connector

var selection_outline: Node2D = Node2D.new()

var previous_origin_pos: Vector2
var previous_target_pos: Vector2

var midpoints: PackedVector2Array
var midpoint_handles: Array[Handle] = []
var new_midpoint_handle: Handle = Handle.new()

var error_indicator: Node2D

var has_errors: bool = false:
	set(value):
		has_errors = value
		if error_indicator:
			error_indicator.visible = has_errors

# Select Tool
var touchable_outline: PackedVector2Array = []
var children_needs_update: bool = true

func _ready():
	self.add_child(selection_outline)
	self.add_child(new_midpoint_handle)
	new_midpoint_handle.visible = false

static func create_connector(type_name: String, origin_point: Vector2 = Vector2(), target_point: Vector2 = Vector2()) -> Connector:
	var connector: Connector
	match type_name:
		"Flow":
			connector = FatConnector.new()
		_:
			connector = ThinConnector.new()
			connector.head_size = 20
	connector.set_endpoints(origin_point, target_point)
	connector.line_width = 2.0
	return connector

func _process(_delta: float) -> void:
	assert(origin)
	assert(target)
		
	var new_origin_pos = to_local(origin.global_position)
	var new_target_pos = to_local(target.global_position)
	if new_origin_pos != previous_origin_pos or new_target_pos != previous_target_pos:
		# TODO: [IMPORTANT] Track position change differently, this gets trigger on rounding errors when changing scale.
		previous_origin_pos = new_origin_pos
		previous_target_pos = new_target_pos
		update_connector()

## Updates the diagram node based on a design object.
##
## This method should be called whenever the source of truth is changed.
func _update_from_design_object(object: PoieticObject):
	if not connector:
		self.connector = create_connector(type_name)
		self.add_child(self.connector)

	# Midpoints
	var original_midpoints = object.get_attribute("midpoints")
	if original_midpoints == null:
		pass
	elif original_midpoints as PackedVector2Array:
		prints("setting mids: ", original_midpoints)
		self.midpoints = original_midpoints
	else:
		printerr("Invalid midpoints type ", original_midpoints.get_class(), " for object ", self.object_id)

	children_needs_update = true

func set_connector(origin: DiagramNode, target: Node2D):
	self.origin = origin
	self.target = target
	update_connector()
	
func update_connector():
	assert(connector)
	assert(origin)
	assert(target)
	
	var target_shape: Shape2D
	if target is DiagramNode:
		target_shape = target.shape
	else:
		target_shape = CircleShape2D.new()
		target_shape.radius = 10

	var points = DiagramGeometry.shape_clipped_connection(origin.shape, origin.global_transform, target_shape, target.global_transform)
	
	var arrow_origin = to_local(points[0])
	var arrow_target = to_local(points[1])
	connector.set_endpoints(arrow_origin, arrow_target)
	
	var polygons = Geometry2D.offset_polyline([arrow_origin, arrow_target], 10, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	if len(polygons) >= 1:
		touchable_outline = polygons[0]
	else:
		touchable_outline = []

	update_midpoint_handles()
	update_selection()
	queue_redraw()
	
func update_midpoint_handles():
	assert(origin)
	assert(target)

	if len(midpoints) == len(midpoint_handles):
		for index in range(len(midpoints)):
			var handle = midpoint_handles[index]
			var point  = midpoints[index]
			handle.position = point
	else:
		for handle in midpoint_handles:
			handle.queue_free()
		midpoint_handles.clear()
		
		for midpoint in midpoints:
			var handle = Handle.new()
			handle.position = midpoint
			handle.visible = true # self.is_selected
			self.add_child(handle)

	if midpoints.is_empty():
		if not new_midpoint_handle:
			new_midpoint_handle = Handle.new()
			self.add_child(new_midpoint_handle)
		var direction = connector.origin_point.direction_to(connector.target_point)
		var length = connector.origin_point.distance_to(connector.target_point)
		var midpoint = (connector.origin_point) + (direction * (length / 2))

		new_midpoint_handle.position = midpoint
		new_midpoint_handle.visible = self.is_selected
	else:
		new_midpoint_handle.visible = false
	
func update_selection():
	if is_selected:
		var selection_outline_width: float = 10
		if type_name == "Flow":
			selection_outline_width = 15

		# TODO: Recycle polygons?
		var polygons = connector.selection_outline()
		for child in selection_outline.get_children():
			child.queue_free()

		if len(polygons) >= 1:
			for points in polygons:
				var fill: Polygon2D = Polygon2D.new()
				fill.color = DiagramCanvas.default_selection_color.darkened(0.5)
				fill.polygon = points
				fill.z_index = 0
				selection_outline.add_child(fill)
				var outline: Line2D = Line2D.new()
				outline.default_color = DiagramCanvas.default_selection_color
				outline.closed = true
				outline.points = points
				outline.width = 2
				outline.z_index = 1
				selection_outline.add_child(outline)
		selection_outline.visible = true

		if midpoints.is_empty():
			new_midpoint_handle.visible = true
		else:
			for handle in midpoint_handles:
				handle.visible = true

	else:
		selection_outline.visible = false
		new_midpoint_handle.visible = false
		for handle in midpoint_handles:
			handle.visible = false

	for handle in midpoint_handles:
		handle.visible = is_selected

func contains_point(point: Vector2):
	var local = to_local(point)
	return Geometry2D.is_point_in_polygon(local, touchable_outline)

# On midpoints:
# No midpoint: have a "suggested midpoint" in the ((target - origin) / 2) arrow vector
# Midpoint: When an endpoint location changes, recalculate midpoints
