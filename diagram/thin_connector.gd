class_name ThinConnector extends Connector

## Shape of the arrow head, at the target point.
@export var head_type: ArrowheadType = ArrowheadType.STICK:
	set(value):
		head_type = value
		queue_redraw()

## Shape of the arrow tail, at the origin point.
@export var tail_type: ArrowheadType = ArrowheadType.NONE:
	set(value):
		tail_type = value
		queue_redraw()

## Shape of the arrow tail, at the origin point.
@export var tail_size: float = head_size:
	set(value):
		tail_size = value
		queue_redraw()

enum ArrowStyle {
	STRAIGHT,
	CURVED,
	ORTHOGONAL
}

enum ArrowheadType {
	NONE,          # No arrow-head
	STICK,         # Simple stick arrowhead
	DIAMOND,       # Diamond-shaped arrowhead
	BOX,        # BOX-shaped arrowhead
	BAR,           # Bar or tee-shaped arrowhead (negative control)
	NON_NAVIGABLE, # X-like cross
	NEGATIVE,      # Negative control (a bar at the endpoint)
	BALL,        # BALL touching the endpoint
	BALL_CENTER  # BALL centered at the endpoint
}

class Arrowhead:
	var curves: Array[Curve2D]
	var offset: float
	
	func _init(curves: Array[Curve2D], offset: float):
		self.curves = curves
		self.offset = offset
		

func _draw():
	var polylines: Array[PackedVector2Array]
	
	for curve in arrow_curves():
		var points: PackedVector2Array = curve.tessellate()
		polylines.append(points)
	if outline_visible:
		for points in polylines:
			if len(points) < 2:
				continue
			draw_polyline(points,  outline_color, outline_width * 2, true)
	for points in polylines:
		if len(points) < 2:
			continue
		draw_polyline(points, line_color, line_width)

func set_endpoints(origin: Vector2, target: Vector2):
	self.origin_point = origin
	self.target_point = target
	queue_redraw()

const arrow_size: float = 30

func arrow_curves() -> Array[Curve2D]:
	# TODO: Merge with selection_outline() (uses shared code)
	var target_direction: Vector2
	var origin_direction: Vector2
	if midpoints.is_empty():
		target_direction = origin_point.direction_to(target_point)
		origin_direction = target_point.direction_to(origin_point)
	else:
		target_direction = midpoints[-1].direction_to(target_point)
		origin_direction = midpoints[0].direction_to(origin_point)

	var head_arrowhead: Arrowhead = create_arrowhead(target_point, target_direction, head_size, head_type)
	var tail_arrowhead: Arrowhead = create_arrowhead(origin_point, origin_direction, tail_size, tail_type)

	var clipped_origin = origin_point - (origin_direction * tail_arrowhead.offset)
	var clipped_target = target_point - (target_direction * head_arrowhead.offset)

	var curves: Array[Curve2D] = tail_arrowhead.curves + head_arrowhead.curves

	var line: Curve2D
	if midpoints.is_empty():
		line = straight_arrow_line(clipped_origin, clipped_target, midpoints)
	else:
		line = curved_arrow_line(clipped_origin, clipped_target, midpoints[0])
	curves.append(line)

	return curves

func straight_arrow_line(origin: Vector2, target: Vector2, midpoints: PackedVector2Array) -> Curve2D:
	var line: Curve2D = Curve2D.new()
	line.add_point(origin)
	
	for point in midpoints:
		line.add_point(point)
	
	line.add_point(target)
	return line

func curved_arrow_line(origin: Vector2, target: Vector2, midpoint: Vector2) -> Curve2D:
	# Catmull-Rom Style Interpolation	
	var curve = Curve2D.new()
	var alpha = 0.5
	var beta  = 0.5
	curve.add_point(origin, Vector2.ZERO, (midpoint - origin) / 6.0)
	curve.add_point(midpoint, -(target - origin) / 6.0, + (target-origin) / 6.0)
	curve.add_point(target, -(target - midpoint) / 6.0, Vector2.ZERO)
	
	return curve
	
func selection_outline(width: float = selection_outline_width) -> Array[PackedVector2Array]:
	# TODO: Merge with draw (uses shared code)
	var result: Array[PackedVector2Array] = []

	for curve in arrow_curves():
		var points = curve.tessellate()
		if len(points) >= 2:
			var out = Geometry2D.offset_polyline(points, width, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
			result.append_array(out)

	if len(result) > 1:
		var combined = result[0]
		for index in range(1, len(result)):
			combined = Geometry2D.merge_polygons(combined, result[index])
		result = combined

	return result


## Offset of the intended arrow endpoint and where it should actually connect to the arrowhead.
##
## For stick, bar, negative and non-navigable arrowheads it is 0, that means that the endpoint
## is the same as intended.
##
## For diamond, box and ball they are offset by the shape size. For ball-center it is offset by
## 1/2 of a size to make the bal center by at the intended enpoint yet the line connect to the
## ball shape from the outside.
##
func get_touch_point_offset(size: float, type: ArrowheadType = ArrowheadType.STICK) -> float:
	match type:
		ArrowheadType.NONE, ArrowheadType.STICK:
			return 0
		ArrowheadType.DIAMOND, ArrowheadType.BOX, ArrowheadType.BALL:
			return size
		ArrowheadType.BAR, ArrowheadType.NEGATIVE, ArrowheadType.NON_NAVIGABLE:
			return 0
		ArrowheadType.BALL_CENTER:
			return size / 2
		_:
			return 0

func create_arrowhead(head_point: Vector2, direction: Vector2, size: float = 10.0, type: ArrowheadType = ArrowheadType.STICK) -> Arrowhead:
	var curves: Array[Curve2D] = []
	var curve = Curve2D.new()
	var perpendicular = direction.orthogonal()
	
	match type:
		ArrowheadType.NONE:
			pass
		ArrowheadType.STICK:
			var point1 = head_point - (direction * size * 1.5) + (perpendicular * size/2)
			var point2 = head_point - (direction * size * 1.5) - (perpendicular * size/2)
			curve.add_point(point1)
			curve.add_point(head_point)
			curve.add_point(point2)
		
		ArrowheadType.DIAMOND:
			var back = head_point - direction * size 
			var side1 = head_point - direction * (size / 2) + perpendicular * (size/2)
			var side2 = head_point - direction * (size / 2) - perpendicular * (size/2)
			curve.add_point(side1)
			curve.add_point(head_point)
			curve.add_point(side2)
			curve.add_point(back)
			curve.add_point(side1)
		
		ArrowheadType.BOX:
			var c1 = head_point - perpendicular * (size / 2)
			var c2 = c1 - direction * size
			var c3 = c2 + perpendicular * size
			var c4 = c3 + direction * size
			curve.add_point(c1)
			curve.add_point(c2)
			curve.add_point(c3)
			curve.add_point(c4)
			curve.add_point(c1)
		
		ArrowheadType.BAR:
			var point1 = head_point - direction * (size / 2) - perpendicular * (size / 2)
			var point2 = head_point - direction * (size / 2) + perpendicular * (size / 2)
			curve.add_point(point1)
			curve.add_point(point2)

		ArrowheadType.NEGATIVE:
			var point1 = head_point - perpendicular * (size / 2)
			var point2 = head_point + perpendicular * (size / 2)
			curve.add_point(point1)
			curve.add_point(point2)
		
		ArrowheadType.NON_NAVIGABLE:  # X-shaped
			var c1 = head_point - direction * (size) - perpendicular * (size / 2)
			var c2 = c1 - direction * size
			var c3 = c2 + perpendicular * size
			var c4 = c3 + direction * size
			curve.add_point(c1)
			curve.add_point(c3)
			curves.append(curve)
			curve = Curve2D.new()
			curve.add_point(c4)
			curve.add_point(c2)
		
		ArrowheadType.BALL:
			var radius = size / 2
			var centre = head_point - direction * radius
			curve = DiagramGeometry.circle_curve(centre, radius)
	
		ArrowheadType.BALL_CENTER:
			var radius = size / 2
			var centre = head_point
			curve = DiagramGeometry.circle_curve(centre, radius)

	curves.append(curve)
	var arrowhead = Arrowhead.new(curves, get_touch_point_offset(size,type))
	return arrowhead

## Get a polygon underneath the arrowhead
#func create_arrowhead_mask(head_point: Vector2, direction: Vector2, size: float = 10.0, type: ArrowheadType = ArrowheadType.STICK) -> PackedVector2Array:
	#const line_width: float = 1.0
	#var curve = Curve2D.new()
	#var perpendicular = direction.orthogonal()
	#
	#match type:
		#ArrowheadType.NONE:
			#pass
		#ArrowheadType.STICK:
			#var point1 = head_point - (direction * size * 1.5) + (perpendicular * size/2)
			#var point2 = head_point - (direction * size * 1.5) - (perpendicular * size/2)
			#curve.add_point(point1)
			#curve.add_point(head_point)
			#curve.add_point(point2)
			#curve.add_point(point1)
		#
		#ArrowheadType.DIAMOND:
			#var back = head_point - direction * size 
			#var side1 = head_point - direction * (size / 2) + perpendicular * (size/2)
			#var side2 = head_point - direction * (size / 2) - perpendicular * (size/2)
			#curve.add_point(side1)
			#curve.add_point(head_point)
			#curve.add_point(side2)
			#curve.add_point(back)
			#curve.add_point(side1)
		#
		#ArrowheadType.BOX:
			#var c1 = head_point - perpendicular * (size / 2)
			#var c2 = c1 - direction * size
			#var c3 = c2 + perpendicular * size
			#var c4 = c3 + direction * size
			#curve.add_point(c1)
			#curve.add_point(c2)
			#curve.add_point(c3)
			#curve.add_point(c4)
			#curve.add_point(c1)
		#
		#ArrowheadType.BAR:
			#var point1 = head_point - direction * (size / 2) - perpendicular * (size / 2)
			#var point2 = head_point - direction * (size / 2) + perpendicular * (size / 2)
			#curve.add_point(point1 + direction * line_width)
			#curve.add_point(point1 - direction * line_width)
			#curve.add_point(point2 - direction * line_width)
			#curve.add_point(point2 + direction * line_width)
			#curve.add_point(point1 + direction * line_width)
#
		#ArrowheadType.NEGATIVE:
			#var point1 = head_point - perpendicular * (size / 2)
			#var point2 = head_point + perpendicular * (size / 2)
			#curve.add_point(point1 + direction * line_width)
			#curve.add_point(point1 - direction * line_width)
			#curve.add_point(point2 - direction * line_width)
			#curve.add_point(point2 + direction * line_width)
			#curve.add_point(point1 + direction * line_width)
		#
		#ArrowheadType.NON_NAVIGABLE:  # X-shaped
			#var c1 = head_point - direction * (size) - perpendicular * (size / 2)
			#var c2 = c1 - direction * size
			#var c3 = c2 + perpendicular * size
			#var c4 = c3 + direction * size
			## TODO: Fix this curve
			#curve.add_point(c1)
			#curve.add_point(c3)
			#curve.add_point(c4)
			#curve.add_point(c2)
			#curve.add_point(c1)
		#
		#ArrowheadType.BALL:
			#var radius = size / 2
			#var centre = head_point - direction * radius
			#curve = create_circle_curve(centre, radius)
	#
		#ArrowheadType.BALL_CENTER:
			#var radius = size / 2
			#var centre = head_point
			#curve = create_circle_curve(centre, radius)
#
	#return curve.tesselate()
	#
