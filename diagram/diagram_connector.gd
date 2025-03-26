class_name DiagramConnector extends DiagramObject
# TODO: Rename to DiagramConnector

var origin: DiagramNode
var target: DiagramNode

@export var connector: Connector

var selection_outline: Node2D = Node2D.new()

var previous_origin_pos: Vector2
var previous_target_pos: Vector2

var midpoint_handles: Array[Handle] = []

var error_indicator: Node2D

var has_errors: bool = false:
	set(value):
		has_errors = value
		if error_indicator:
			error_indicator.visible = has_errors

# Select Tool
var touchable_outline: Array[PackedVector2Array] = []
var children_needs_update: bool = true

## Offset of an arrow from s shape
const pretty_arrow_offset: float = 7

func _ready():
	pass
	# self.add_child(selection_outline)

static func create_connector(type_name: String, origin_point: Vector2 = Vector2(), target_point: Vector2 = Vector2()) -> Connector:
	var connector: Connector
	match type_name:
		"Flow":
			connector = FatConnector.new()
		"Parameter":
			connector = ThinConnector.new()
			connector.head_size = 20
			connector.tail_size = 15
			connector.head_type = ThinConnector.ArrowheadType.STICK
			connector.tail_type = ThinConnector.ArrowheadType.BALL
		_:
			connector = ThinConnector.new()
			connector.head_size = 20
	connector.outline_color = DiagramCanvas.default_selection_color
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

func get_handles() -> Array[Handle]:
	return midpoint_handles

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
		self.connector.midpoints = []
	elif original_midpoints is PackedVector2Array:
		self.connector.midpoints = original_midpoints
	elif original_midpoints != null:
		printerr("Invalid midpoints type ", original_midpoints.get_class(), " for object ", self.object_id)

	children_needs_update = true

	
func update_connector():
	# TODO: Review where and how many times this update is called
	assert(connector)
	assert(origin)
	assert(target)
	
	var target_shape: Shape2D
	if target is DiagramNode:
		target_shape = target.shape
	else:
		target_shape = CircleShape2D.new()
		target_shape.radius = 10

	var origin_lead: Vector2 # Next point after the origin point
	var target_lead: Vector2 # Last point before the target point
	if connector.midpoints.is_empty():
		origin_lead = target.position
		target_lead = origin.position
	else:
		origin_lead = connector.midpoints[-1]
		target_lead = connector.midpoints[0]
	
	var origin_clips = DiagramGeometry.intersect_line_with_shape(origin_lead, origin.position, origin.shape, origin.position)
	var target_clips = DiagramGeometry.intersect_line_with_shape(target_lead, target.position, target.shape, target.position)
	
	var arrow_origin: Vector2
	var arrow_target: Vector2
	
	if origin_clips.is_empty():
		arrow_origin = origin.position
	else:
		arrow_origin = origin_clips[0]
		
	if target_clips.is_empty():
		arrow_target = target.position
	else:
		arrow_target = target_clips[0]
	
	# Pretty offset
	var origin_offset = arrow_origin.direction_to(origin_lead) * pretty_arrow_offset
	var target_offset = arrow_target.direction_to(target_lead) * pretty_arrow_offset
	
	connector.set_endpoints(arrow_origin + origin_offset, arrow_target + target_offset)
	
	touchable_outline = connector.selection_outline(10)

	update_midpoint_handles()
	update_selection()
	queue_redraw()
	
## Update the midpoint handles based on the connector's midpoints.
##
## This method is called when midpoints are added or removed from the connector.
func update_midpoint_handles():
	assert(origin)
	assert(target)

	var midpoint_count = len(connector.midpoints)
	var handle_count = len(midpoint_handles)

	if midpoint_count == 0:
		# First midpoint
		assert(handle_count <= 1, "Midpoint hadles were not properely reset")
		var handle: Handle
		
		if handle_count == 0:
			handle = Handle.new()
			handle.color = DiagramCanvas.handle_color
			handle.outline_color = DiagramCanvas.handle_outline_color
			self.add_child(handle)
		else:
			handle = midpoint_handles[0]
			
		var direction = connector.origin_point.direction_to(connector.target_point)
		var length = connector.origin_point.distance_to(connector.target_point)
		handle.position = (connector.origin_point) + (direction * (length / 2))
		handle.index = -1
		midpoint_handles.assign([handle])
	else:
		for index in range(midpoint_count):
			var midpoint  = connector.midpoints[index]
			var handle: Handle
			if index < handle_count:
				handle = midpoint_handles[index]
			else:
				handle = Handle.new()
				midpoint_handles.append(handle)
				self.add_child(handle)
			handle.index = index  # Reset the index
			handle.position = midpoint
		var remaining = handle_count - midpoint_count
		if remaining > 0:
			for index in range(remaining):
				midpoint_handles.remove_at(midpoint_count)

	assert(len(midpoint_handles) > 0, "There must be always at least one midpoint handle")

func set_midpoint(index: int, midpoint_position: Vector2):
	if index == -1:
		connector.midpoints = [midpoint_position]
		# This was the first handle, now it is included
		midpoint_handles[0].index = 0
	else:
		connector.midpoints.set(index, midpoint_position)
	update_connector()

func update_selection():
	connector.outline_visible = is_selected
	for handle in midpoint_handles:
		handle.visible = is_selected

func contains_point(point: Vector2):
	var local = to_local(point)
	for outline in touchable_outline:
		if Geometry2D.is_point_in_polygon(local, outline):
			return true
	return false

# On midpoints:
# No midpoint: have a "suggested midpoint" in the ((target - origin) / 2) arrow vector
# Midpoint: When an endpoint location changes, recalculate midpoints
