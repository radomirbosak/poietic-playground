class_name ShapeCreator extends Node

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
			return []
