class_name DiagramConnection extends Node2D

var line: Line2D
var origin: DiagramNode
var target: Node2D

	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.line = Line2D.new()
	self.line.name = "line"
	self.line.default_color = Color.GREEN
	self.line.width = 2.0
	
	add_child(line)

@warning_ignore("shadowed_variable")
func set_connection(origin: DiagramNode, target: Node2D):
	self.origin = origin
	self.target = target
	update_shape()

@warning_ignore("shadowed_variable")
func set_target(target: DiagramNode):
	self.target = target
	update_shape()
	
func update_shape():
	if origin == null or target == null:
		push_warning("Updating connector shape without origin or target")
		return
	line.clear_points()
	
	var origin_center = to_global(origin.position)
	var target_center = to_global(target.position)

	var radius = origin.shape.radius
	var origin_inter = intersect_line_with_circle(origin_center,target_center, origin_center, radius)
	if len(origin_inter) >= 1:
		line.add_point(to_local(origin_inter[0]))
	else:
		line.add_point(to_local(origin_center))

	if target is DiagramNode:
		var target_inter = intersect_line_with_circle(origin_center,target_center, target_center, radius)
		if len(target_inter) >= 1:
			line.add_point(to_local(target_inter[0]))
		else:
			line.add_point(to_local(target_center))
	else:
		line.add_point(to_local(target_center))
		
func intersect_line_with_circle(point_a: Vector2, point_b: Vector2, center: Vector2, radius: float) -> Array[Vector2]:
	# Define the line as a parametric equation: P = line_start + t * (line_end - line_start)
	var d = point_b - point_a
	var f = point_a - center

	# Quadratic equation coefficients
	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - radius * radius

	# Solve the quadratic equation: at^2 + bt + c = 0
	var discriminant = b * b - 4 * a * c

	if discriminant < 0:
		# No intersection
		return []

	discriminant = sqrt(discriminant)

	# Compute the two solutions for t
	var t1 = (-b - discriminant) / (2 * a)
	var t2 = (-b + discriminant) / (2 * a)

	var intersections: Array[Vector2] = []

	# Check if t1 and t2 are valid
	if 0 <= t1 and t1 <= 1:
		intersections.append(point_a + t1 * d)
	if 0 <= t2 and t2 <= 1:
		intersections.append(point_a + t2 * d)

	return intersections
