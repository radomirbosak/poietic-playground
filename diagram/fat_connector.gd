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
@export var fill_color: Color = Color.DARK_GRAY

enum ArrowStyle {
	STRAIGHT,
	CURVED,
	ORTHOGONAL
}

enum ArrowheadType {
	NONE,           # No arrow-head
	REGULAR,        # Simple outlined arrowhead
}

class Arrowhead:
	var polygon: PackedVector2Array
	var offset: float
	
	func _init(polygon: PackedVector2Array, offset: float):
		self.polygon = polygon
		self.offset = offset

func _init():
	self.fill_color = Color.DIM_GRAY
	self.fill_color.a = 0.5

func _draw():
	var polygons = arrow_polygons()
	
	if outline_visible:
		for points in selection_outline():
			draw_polygon(points, [outline_color])
	
	for poly in polygons:
		if poly[-1] != poly[0]:
			poly.append(poly[0])
		draw_polygon(poly, [fill_color])
		draw_polyline(poly, line_color, line_width)

## Create an arrowhead that will be combined with the rest of the line outline.
##
## If the arrow head type is none/unknown, then it returns an empty array.
##
## The caller is expected to offset the outline from the head point by the head
## size, if a polygon points are returned. Otherwise the head point should
## remain the same.
##
func arrowhead(end_point: Vector2, direction: Vector2, type: ArrowheadType) -> Arrowhead:
	var perpendicular = direction.orthogonal()
	var p1: Vector2
	var p2: Vector2
	var points: PackedVector2Array = PackedVector2Array()
	if type == ArrowheadType.REGULAR:
		p1 = end_point - (direction * head_size) + (perpendicular * head_size / 2)
		p2 = p1 - (perpendicular * head_size)
		# points += [p1, a1, target_point, a2, p2]
		# points = [p2, end_point, p1, p2]
		points = [p2, p1, end_point, p2]
		return Arrowhead.new(points, head_size)
	else:
		return Arrowhead.new(points, 0)

func arrow_polygons() -> Array[PackedVector2Array]:
	var direction = (target_point - origin_point).normalized()
	var perpendicular = direction.orthogonal()
	var points: PackedVector2Array = PackedVector2Array()

	var origin_lead: Vector2 # Next point after the origin point
	var target_lead: Vector2 # Last point before the target point
	if midpoints.is_empty():
		origin_lead = target_point
		target_lead = origin_point
	else:
		origin_lead = midpoints[-1]
		target_lead = midpoints[0]

	var origin_direction = origin_lead.direction_to(origin_point)
	var target_direction = target_lead.direction_to(target_point)

	var head_arrowhead = arrowhead(target_point, target_direction, head_type)
	var tail_arrowhead = arrowhead(origin_point, origin_direction, tail_type)

	var clipped_origin = origin_point - (origin_direction * (tail_arrowhead.offset + width/2))
	var clipped_target = target_point - (target_direction * (head_arrowhead.offset + width/2))

	var polyline: PackedVector2Array = [clipped_origin]
	for point in midpoints:
		polyline.append(point)
	polyline.append(clipped_target)
	
	var outline = Geometry2D.offset_polyline(polyline, width, Geometry2D.JOIN_SQUARE, Geometry2D.END_SQUARE)
	# TODO: We need to combine multiple polygons properly
	var combined: Array[PackedVector2Array]
	combined = Geometry2D.merge_polygons(head_arrowhead.polygon, outline[0])
	combined = Geometry2D.merge_polygons(combined[0], tail_arrowhead.polygon)

	return combined

func selection_outline(width: float = selection_outline_width) -> Array[PackedVector2Array]:
	var polygons: Array[PackedVector2Array] = []
	for poly in arrow_polygons():
		var offset = Geometry2D.offset_polygon(poly, width, Geometry2D.JOIN_ROUND)
		polygons.append_array(offset)
	return polygons
