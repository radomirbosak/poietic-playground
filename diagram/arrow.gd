class_name Arrow extends Node2D

var type_name: String = "Flow"

var head: Vector2 = Vector2()
var tail: Vector2 = Vector2()

var head_type: ArrowheadType = ArrowheadType.SQUARE
var tail_type: ArrowheadType = ArrowheadType.DIAMOND

enum ArrowheadType {
	NONE,          # No arrow-head
	STICK,         # Simple stick arrowhead
	DIAMOND,       # Diamond-shaped arrowhead
	SQUARE,        # Square-shaped arrowhead
	BAR,           # Bar or tee-shaped arrowhead (negative control)
	NON_NAVIGABLE, # X-like cross
	NEGATIVE,      # Negative control (a bar at the endpoint)
	CIRCLE,        # Circle touching the endpoint
	CIRCLE_CENTER  # Circle centered at the endpoint
}

class Arrowhead:
	var polygons: Array[PackedVector2Array]
	var polylines: Array[PackedVector2Array]
	var offset: float
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	# queue_redraw()
	pass

func _draw():
	draw_arrow()


func draw_arrow():
	# TODO: Rewrite nicely
	const arrow_size: float = 30
	var normal = (tail - head).normalized()

	draw_line(tail, head, Color.WHITE, 4.0)

	var tail_curve = create_arrowhead(head, tail, 40, tail_type)
	var tail_points = tail_curve.tessellate()
	if len(tail_points) >= 2:
		draw_colored_polygon(tail_points, Color.CORAL)
		draw_polyline(tail_points, Color.WHITE, 4.0)
	else:
		prints("No points for tail ", tail_type, tail_points)
	
	var head_curve = create_arrowhead(tail, head, 40, head_type)
	var head_points = head_curve.tessellate()
	if len(head_points) >= 2:
		draw_colored_polygon(head_points, Color.CORAL)
		draw_polyline(head_points, Color.WHITE, 4.0)
	else:
		prints("No points for head ", head_type, head_points)


func get_touch_point_offset(size: float, type: ArrowheadType = ArrowheadType.STICK) -> float:
	match type:
		ArrowheadType.NONE, ArrowheadType.STICK:
			return 0
		ArrowheadType.DIAMOND, ArrowheadType.SQUARE, ArrowheadType.CIRCLE:
			return size
		ArrowheadType.BAR, ArrowheadType.NEGATIVE, ArrowheadType.NON_NAVIGABLE:
			return 0
		ArrowheadType.CIRCLE_CENTER:
			return size / 2
	return 0

func create_arrowhead(origin: Vector2, target: Vector2, size: float = 10.0, type: ArrowheadType = ArrowheadType.STICK) -> Curve2D:
	var curve = Curve2D.new()
	var direction = (target - origin).normalized()
	var perpendicular = direction.orthogonal()
	
	match type:
		ArrowheadType.NONE:
			pass
		ArrowheadType.STICK:
			var point1 = target - (direction * size) + (perpendicular * size/2)
			var point2 = target - (direction * size) - (perpendicular * size/2)
			curve.add_point(point1)
			curve.add_point(target)
			curve.add_point(point2)
		
		ArrowheadType.DIAMOND:
			var back = target - direction * size 
			var side1 = target - direction * (size / 2) + perpendicular * (size/2)
			var side2 = target - direction * (size / 2) - perpendicular * (size/2)
			curve.add_point(side1)
			curve.add_point(target)
			curve.add_point(side2)
			curve.add_point(back)
			curve.add_point(side1)
		
		ArrowheadType.SQUARE:
			var c1 = target - perpendicular * (size / 2)
			var c2 = c1 - direction * size
			var c3 = c2 + perpendicular * size
			var c4 = c3 + direction * size
			curve.add_point(c1)
			curve.add_point(c2)
			curve.add_point(c3)
			curve.add_point(c4)
			curve.add_point(c1)
		
		ArrowheadType.BAR:
			var point1 = target - direction * (size / 2) - perpendicular * (size / 2)
			var point2 = target - direction * (size / 2) + perpendicular * (size / 2)
			curve.add_point(point1)
			curve.add_point(point2)

		ArrowheadType.NEGATIVE:
			var point1 = target - perpendicular * (size / 2)
			var point2 = target + perpendicular * (size / 2)
			curve.add_point(point1)
			curve.add_point(point2)
		
		ArrowheadType.NON_NAVIGABLE:
			var c1 = target - perpendicular * (size / 2)
			var c2 = c1 - direction * size
			var c3 = c2 + perpendicular * size
			var c4 = c3 + direction * size
			curve.add_point(c1)
			curve.add_point(c3)
			curve.add_point(c4)
			curve.add_point(c2)
		
		ArrowheadType.CIRCLE:
			var radius = size / 2
			var centre = target - direction * radius
			curve = create_circle_curve(centre, radius)
	
		ArrowheadType.CIRCLE_CENTER:
			var radius = size / 2
			var centre = target
			curve = create_circle_curve(centre, radius)

	return curve

func create_circle_curve(center: Vector2, radius: float) -> Curve2D:
	# https://spencermortensen.com/articles/bezier-circle/
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
