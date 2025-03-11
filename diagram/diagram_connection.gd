class_name DiagramConnection extends Node2D

# DampedSpringJoint2D
# Diagram Properties
var type_name: String
var object_id: int
var origin: DiagramNode
var target: Node2D

var label: String

var arrow_origin: Vector2 = Vector2()
var arrow_target: Vector2 = Vector2()
var previous_origin_pos: Vector2
var previous_target_pos: Vector2

# Physics
# var joint: DampedSpringJoint2D

# Select Tool
var touchable_outline: PackedVector2Array = []
var is_selected: bool = false

var children_needs_update: bool = true

func queue_layout():
	children_needs_update = true

func _process(_delta: float) -> void:
	if not origin:
		# push_error("Connection ", self, " has no origin")
		return
	if not target:
		# push_error("Connection ", self, " has no target")
		return
		
	var new_origin_pos = to_local(origin.global_position)
	var new_target_pos = to_local(target.global_position)
	if new_origin_pos != previous_origin_pos or new_target_pos != previous_target_pos:
		previous_origin_pos = new_origin_pos
		previous_target_pos = new_target_pos
		update_arrow()

## Updates the diagram node based on a design object.
##
## This method should be called whenever the source of truth is changed.
func update_from(object: PoieticObject):
	var position = object.get_position()
	
	if position is Vector2:
		self.position = position
	else:
		self.position = Vector2()
		
	var text = object.name
	if text is String:
		self.label = text

	queue_layout()

func set_connection(origin: DiagramNode, target: Node2D):
	self.origin = origin
	self.target = target
	# TODO: Physics
	# if joint == null:
		#joint = DampedSpringJoint2D.new()
		#add_child(joint)
	#if joint != null:
		#joint.node_a = joint.get_path_to(origin)
		#joint.node_b = joint.get_path_to(target)
	update_arrow()
	
func set_target(target: DiagramNode):
	self.target = target
	update_arrow()
	
func _draw() -> void:
	draw_arrow()

func update_arrow():
	if origin == null or target == null:
		push_warning("Updating connector shape without origin or target")
		return

	var target_shape: Shape2D
	if target is DiagramNode:
		target_shape = target.shape
	else:
		target_shape = CircleShape2D.new()
		target_shape.radius = 10

	var points = DiagramGeometry.shape_clipped_connection(origin.shape, origin.global_transform, target_shape, target.global_transform)
	arrow_origin = to_local(points[0])
	arrow_target = to_local(points[1])
	var polygons = Geometry2D.offset_polyline([arrow_origin, arrow_target], 10, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	if len(polygons) >= 1:
		touchable_outline = polygons[0]
	else:
		touchable_outline = []
	
	queue_redraw()

func draw_arrow():
	# TODO: Rewrite nicely
	const arrow_size: float = 30
	var normal = (arrow_target - arrow_origin).normalized()
	match type_name:
		"Flow":
			var head_points = DiagramGeometry.arrow_points(arrow_origin, arrow_target, DiagramGeometry.ArrowHeadType.STICK, arrow_size, 30)
			var l_origin = arrow_origin + normal.rotated(-90)*5
			var l_target = arrow_target + normal.rotated(-90)*5
			var r_origin = arrow_origin + normal.rotated(+90)*5
			var r_target = arrow_target + normal.rotated(+90)*5
			var loffset = normal.rotated(-90)*5
			var roffset = normal.rotated(+90)*5
			var points = PackedVector2Array()
			var lhead = l_target-(head_points[1]-head_points[0]).project(l_target - l_origin)
			var rhead = r_target-(head_points[1]-head_points[2]).project(r_target - r_origin)
			points = [
				l_origin,
				# arrow_target+loffset,
				lhead,
				head_points[0],
				head_points[1],
				head_points[2],
				rhead,
				r_origin,
				l_origin
			]
			draw_polyline(points, DiagramCanvas.default_pictogram_color, 2.0)

			if len(head_points) > 0:
				draw_polyline(head_points, DiagramCanvas.default_pictogram_color, 2.0)
				
			if is_selected:
				var polygons = Geometry2D.offset_polyline([arrow_origin, arrow_target], 15, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
				if len(polygons) >= 1:
					draw_polyline(polygons[0], DiagramCanvas.default_selection_color, 2.0)
		_:
			var head_points = DiagramGeometry.arrow_points(arrow_origin, arrow_target, DiagramGeometry.ArrowHeadType.STICK, arrow_size, 15)
			draw_line(arrow_origin, arrow_target, DiagramCanvas.default_pictogram_color, 2.0)

			if len(head_points) > 0:
				draw_polyline(head_points, DiagramCanvas.default_pictogram_color, 2.0)
				
			if is_selected:
				var polygons = Geometry2D.offset_polyline([arrow_origin, arrow_target], 10, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
				if len(polygons) >= 1:
					draw_polyline(polygons[0], DiagramCanvas.default_selection_color, 2.0)



func set_selected(flag: bool):
	self.is_selected = flag
	queue_redraw()

func contains_point(point: Vector2):
	var local = to_local(point)
	return Geometry2D.is_point_in_polygon(local, touchable_outline)
