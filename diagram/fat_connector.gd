class_name FatConnector extends Connector

## Shape of the arrow head, at the target point.
@export var head_type: ArrowheadType = ArrowheadType.REGULAR:
	set(value):
		head_type = value
		queue_redraw()

## Shape of the arrow tail, at the origin point.
@export var tail_type: ArrowheadType = ArrowheadType.NONE:
	set(value):
		tail_type = value
		queue_redraw()

# Outline (move to separate node type)
@export var width: float = 10.0

enum ArrowStyle {
	STRAIGHT,
	CURVED,
	ORTHOGONAL
}

enum ArrowheadType {
	NONE,           # No arrow-head
	REGULAR,        # Simple outlined arrowhead
}

func _draw():
	var points = arrow_points()
	draw_polyline(points, line_color, line_width)

func arrow_points() -> PackedVector2Array:
	var direction = (target_point - origin_point).normalized()
	var perpendicular = direction.orthogonal()
	var points: PackedVector2Array = PackedVector2Array()
	var p1: Vector2
	var p2: Vector2
	
	if head_type == ArrowheadType.REGULAR:
		p1 = target_point - (direction * head_size) + (perpendicular * width / 2)
		p2 = p1 - perpendicular * width
		var a1 = p1 + perpendicular * ((head_size / 2) - (width / 2))
		var a2 = p2 - perpendicular * ((head_size / 2) - (width / 2))

		# points += [p1, a1, target_point, a2, p2]
		points.append_array([p2, a2, target_point, a1, p1])
	else:
		p1 = target_point + (perpendicular * width / 2)
		p2 = p1 - perpendicular * width
		points.append_array([p2, p1])
	
	if tail_type == ArrowheadType.REGULAR:
		var p4 = origin_point + (direction * head_size) + (perpendicular * width / 2)
		var p3 = p4 - perpendicular * width
		var a4 = p4 + perpendicular * ((head_size / 2) - (width / 2))
		var a3 = p3 - perpendicular * ((head_size / 2) - (width / 2))

		points.append_array([p4, a4, origin_point, a3, p3])
	else:
		var p4 = origin_point + (perpendicular * width / 2)
		var p3 = p4 - perpendicular * width
		points.append_array([p4, p3])

	points.append(p2)
	return points
