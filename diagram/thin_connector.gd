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
	draw_simple_arrow()

func set_endpoints(origin: Vector2, target: Vector2):
	self.origin_point = origin
	self.target_point = target
	queue_redraw()

const arrow_size: float = 30

func draw_simple_arrow():
	for curve in arrow_curves():
		var points = curve.tessellate()
		if len(points) >= 2:
			# draw_colored_polygon(points, Color.CORAL)
			draw_polyline(points, line_color, line_width)

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
	var tail_arrowhead: Arrowhead = create_arrowhead(origin_point, origin_direction, head_size, tail_type)

	var clipped_origin = origin_point + (origin_direction * tail_arrowhead.offset)
	var clipped_target = target_point - (target_direction * head_arrowhead.offset)

	var curves: Array[Curve2D] = tail_arrowhead.curves + head_arrowhead.curves

	var line: Curve2D = Curve2D.new()
	line.add_point(clipped_origin)
	
	for point in midpoints:
		line.add_point(point)
	
	line.add_point(clipped_target)
	curves.append(line)

	return curves
	
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
			curve = create_circle_curve(centre, radius)
	
		ArrowheadType.BALL_CENTER:
			var radius = size / 2
			var centre = head_point
			curve = create_circle_curve(centre, radius)

	curves.append(curve)
	var arrowhead = Arrowhead.new(curves, get_touch_point_offset(size,type))
	return arrowhead

func create_circle_curve(center: Vector2, radius: float) -> Curve2D:
	# https://spencermortensen.com/articles/bezier-BALL/
	# P0=(0,a), P1=(b,c), P2=(c,b), P3=(a,0)
	var curve = Curve2D.new()
	var magic = radius * 0.552285  # Approximation factor for Bézier control points
	var a=1.00005519
	var b=0.55342686
	# var c=0.99873585

	var p1: Vector2 = Vector2()
	var p2: Vector2 = Vector2()
	
	p1 = Vector2(b, 0) * radius
	p2 = Vector2(0, b) * radius
	curve.add_point(center + (Vector2(0, a) * radius), Vector2.ZERO, p1)
	curve.add_point(center + (Vector2(a, 0) * radius), p2, -p2)
	curve.add_point(center + (Vector2(0, -a) * radius), p1, -p1)
	curve.add_point(center + (Vector2(-a, 0) * radius), -p2, p2)
	curve.add_point(center + (Vector2(0, a) * radius), -p1, Vector2.ZERO)

	return curve
