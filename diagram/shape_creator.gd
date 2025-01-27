class_name ShapeCreator extends Node

# TODO: Rename to DiagramGeometry

enum ArrowHeadType {
	NONE, STICK
}

static func arrow_points(tail: Vector2, head: Vector2, type: ArrowHeadType, size: float) -> Array[Vector2]:
	match type:
		ArrowHeadType.NONE:
			return []
		ArrowHeadType.STICK:
			const angle = (TAU / 360.0) * 15
			var length = size
			var line_vector = head - tail
			var left = line_vector.rotated(angle).normalized() * length
			var right = line_vector.rotated(-angle).normalized() * length
			return [head - left, head, head - right]
		_:
			push_warning("Unknown arrowhead type: ", type)
			return []

static func intersect_line_with_shape(point_a: Vector2, point_b: Vector2, shape: Shape2D, shape_transform: Transform2D = Transform2D()) -> PackedVector2Array:
	if shape is CircleShape2D:
		return intersect_line_with_circle(point_a, point_b, shape_transform.get_origin(), shape.radius)
	elif shape is RectangleShape2D:
		var rect = shape.get_rect()
		var result = intersect_line_with_rect(point_a, point_b, rect, shape_transform)
		return result
	return []

static func intersect_line_with_rect(point_a: Vector2, point_b: Vector2, rect: Rect2, transform: Transform2D) -> PackedVector2Array:
	var corners: PackedVector2Array = transform * rectangle_to_polygon(rect)
	var popo = Geometry2D.clip_polyline_with_polygon([point_a, point_b], corners)
	if len(popo) >= 1:
		return popo[0]
	else:
		return []
	
static func intersect_line_with_circle(point_a: Vector2, point_b: Vector2, center: Vector2, radius: float) -> Array[Vector2]:
	var d = point_b - point_a
	var f = point_a - center

	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - radius * radius

	var discriminant = b * b - 4 * a * c

	if discriminant < 0:
		return []

	discriminant = sqrt(discriminant)

	var t1 = (-b - discriminant) / (2 * a)
	var t2 = (-b + discriminant) / (2 * a)

	var intersections: Array[Vector2] = []

	if 0 <= t1 and t1 <= 1:
		intersections.append(point_a + t1 * d)
	if 0 <= t2 and t2 <= 1:
		intersections.append(point_a + t2 * d)

	return intersections

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
