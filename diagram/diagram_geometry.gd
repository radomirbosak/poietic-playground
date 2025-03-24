class_name DiagramGeometry extends Object

# TODO: Rename to DiagramGeometry

enum ArrowHeadType {
	NONE, STICK
}

static func arrow_points(tail: Vector2, head: Vector2, type: ArrowHeadType, size: float, head_angle: float = 15) -> Array[Vector2]:
	match type:
		ArrowHeadType.NONE:
			return []
		ArrowHeadType.STICK:
			var angle = (TAU / 360.0) * head_angle
			var length = size
			var line_vector = head - tail
			var left = line_vector.rotated(angle).normalized() * length
			var right = line_vector.rotated(-angle).normalized() * length
			return [head - left, head, head - right]
		_:
			push_warning("Unknown arrowhead type: ", type)
			return []

## Get intersection points of a line with a shape.
##
## Used to determine touch-points of a connecting line with a shape of a diagram node.
##
static func intersect_line_with_shape(line_start: Vector2, line_end: Vector2, shape: Shape2D, shape_transform: Transform2D = Transform2D()) -> PackedVector2Array:
	if shape is CircleShape2D:
		return intersect_line_with_circle(line_start, line_end, shape_transform.get_origin(), shape.radius * shape_transform.get_scale().x)
	elif shape is RectangleShape2D:
		var rect = shape.get_rect()
		var result = intersect_line_with_rect(line_start, line_end, rect, shape_transform)
		return result
	elif shape is CapsuleShape2D:
		push_warning("Not implemented: Capsule shape intersection, using circle instead")
		return intersect_line_with_circle(line_start, line_end, shape_transform.get_origin(), shape.radius * shape_transform.get_scale().x)
	return []

static func intersect_line_with_rect(line_start: Vector2, line_end: Vector2, rect: Rect2, transform: Transform2D) -> PackedVector2Array:
	# Define the rectangle's vertices in local space
	var corners = transform * PackedVector2Array([
		Vector2(rect.position.x, rect.position.y),
		Vector2(rect.position.x, rect.position.y + rect.size.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y),
	])

	var result: PackedVector2Array = PackedVector2Array()
	var inter1 = Geometry2D.segment_intersects_segment(corners[0], corners[1], line_start, line_end)
	if inter1:
		result.append(inter1)
	var inter2 = Geometry2D.segment_intersects_segment(corners[1], corners[2], line_start, line_end)
	if inter2:
		result.append(inter2)
	var inter3 = Geometry2D.segment_intersects_segment(corners[2], corners[3], line_start, line_end)
	if inter3:
		result.append(inter3)
	var inter4 = Geometry2D.segment_intersects_segment(corners[3], corners[0], line_start, line_end)
	if inter4:
		result.append(inter4)

	return result
	
	
static func intersect_line_with_circle(line_start: Vector2, line_end: Vector2, center: Vector2, radius: float) -> PackedVector2Array:
	var d = line_end - line_start
	var f = line_start - center

	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - radius * radius

	var discriminant = b * b - 4 * a * c

	if discriminant < 0:
		return []

	discriminant = sqrt(discriminant)

	var t1 = (-b - discriminant) / (2 * a)
	var t2 = (-b + discriminant) / (2 * a)

	var result: PackedVector2Array = PackedVector2Array()

	if 0 <= t1 and t1 <= 1:
		result.append(line_start + t1 * d)
	if 0 <= t2 and t2 <= 1:
		result.append(line_start + t2 * d)

	return result

static func rectangle_to_polygon(rect: Rect2) -> PackedVector2Array:
	var corners: PackedVector2Array = [
		rect.position,
		Vector2(rect.position.x + rect.size.x, rect.position.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y),
		Vector2(rect.position.x, rect.position.y + rect.size.y),
		rect.position,
	]
	return corners

static func rectangle_with_center(center: Vector2, width: float, height: float) -> Rect2:
	return Rect2(center.x - width / 2, center.y - height/2, width, height)

static func grow_shape(shape: Shape2D, factor: float) -> Shape2D:
	if shape is RectangleShape2D:
		var new_shape = RectangleShape2D.new()
		new_shape.size = shape.size * factor
		return new_shape
	elif shape is CircleShape2D:
		var new_shape = CircleShape2D.new()
		new_shape.radius = shape.radius * factor
		return new_shape
	elif shape is CapsuleShape2D:
		var new_shape = CapsuleShape2D.new()
		new_shape.radius = shape.radius * factor
		new_shape.height = shape.height * factor
		return new_shape
	elif shape is ConvexPolygonShape2D:
		var new_shape = ConvexPolygonShape2D.new()
		new_shape.points = grow_polygon(shape.points, factor)
		return new_shape
	else:
		print("Unsupported shape type: ", shape.get_class())
		return shape

static func offset_shape(shape: Shape2D, offset: float) -> Shape2D:
	if shape is RectangleShape2D:
		var new_shape = RectangleShape2D.new()
		new_shape.size = shape.size + Vector2(offset * 2, offset * 2)
		return new_shape
	elif shape is CircleShape2D:
		var new_shape = CircleShape2D.new()
		new_shape.radius = shape.radius + offset
		return new_shape
	elif shape is CapsuleShape2D:
		var new_shape = CapsuleShape2D.new()
		new_shape.radius = shape.radius + (offset)
		new_shape.height = shape.height + (offset * 2)
		return new_shape
	elif shape is ConvexPolygonShape2D:
		var new_shape = ConvexPolygonShape2D.new()
		new_shape.points = offset_polygon(shape.points, offset)
		return new_shape
	else:
		print("Unsupported shape type: ", shape.get_class())
		return shape

static func grow_polygon(polygon: PackedVector2Array, factor: float) -> PackedVector2Array:
	if polygon.is_empty():
		return polygon
	
	var centroid := Vector2.ZERO
	for point in polygon:
		centroid += point
	centroid /= polygon.size()

	var scaled_polygon := PackedVector2Array(polygon)
	for index in range(0, len(polygon)):
		scaled_polygon[index] = centroid + (scaled_polygon[index] - centroid) * factor

	return scaled_polygon

static func offset_polygon(polygon: PackedVector2Array, offset: float) -> PackedVector2Array:
	if polygon.is_empty():
		return polygon
	
	var centroid := Vector2.ZERO
	for point in polygon:
		centroid += point
	centroid /= polygon.size()

	var scaled_polygon := PackedVector2Array(polygon)
	for index in range(0, len(polygon)):
		var vec = scaled_polygon[index] - centroid
		
		scaled_polygon[index] = centroid + (vec.normalized() * (vec.length + offset))

	return scaled_polygon

static func draw_shape(canvas: CanvasItem, shape: Shape2D, color: Color = Color.WHITE, width: float = -1):
	if shape is RectangleShape2D:
		var extents = shape.extents
		canvas.draw_rect(Rect2(-extents, extents * 2), color, false, width)
	elif shape is CircleShape2D:
		canvas.draw_circle(Vector2.ZERO, shape.radius, color, false, width)
	elif shape is CapsuleShape2D:
		var radius = shape.radius
		var height = shape.height
		draw_capsule(canvas, Vector2.ZERO, radius, height, color, width)
	elif shape is ConvexPolygonShape2D:
		var points = shape.points
		canvas.draw_polygon(points, [color])
	else:
		print("Unsupported shape type: ", shape.get_class())

static func draw_capsule(canvas: CanvasItem, position: Vector2, radius: float, height: float, color: Color, width: float = -1.0):
	var half_height = height / 2
	# Draw the two semicircles
	canvas.draw_arc(position + Vector2(0, -half_height), radius, PI, 2 * PI, 32, color, width)
	canvas.draw_arc(position + Vector2(0, half_height), radius, 0, PI, 32, color, width)
	# Draw the two lines connecting the semicircles
	canvas.draw_line(position + Vector2(-radius, -half_height), position + Vector2(-radius, half_height), color, width)
	canvas.draw_line(position + Vector2(radius, -half_height), position + Vector2(radius, half_height), color, width)
