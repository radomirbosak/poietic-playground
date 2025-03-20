class_name ValueIndicator extends Node2D

const DEFAULT_SIZE = Vector2(100, 20)

# TODO: Should be optional float (`float?`?)
var value: Variant:
	set(new_value):
		value = new_value
		queue_redraw()
		
@export var min_value: float
@export var max_value: float
var mid_value: Variant

@export var size: Vector2 = DEFAULT_SIZE

@export var bg_style: StyleBox = StyleBoxLine.new()
@export var normal_style: StyleBox = StyleBoxFlat.new()
@export var overflow_style: StyleBox = StyleBoxFlat.new()
@export var negative_style: StyleBox = StyleBoxFlat.new()
@export var empty_value_style: StyleBox = StyleBoxFlat.new()

func _init():
	negative_style.bg_color = Color.RED
	negative_style.border_color = Color.RED
	overflow_style.bg_color = Color.GREEN_YELLOW


func _draw():
	# TODO: This is drawn also when it is not visible. Make sure not to do that.
	# TODO: Handle overflow
	var overflow = false
	var underflow = false
	const inset: float = 2
	var bg_rect = Rect2(-size/2, size)
	var style: StyleBox = normal_style

	if value is float:
		bg_style.draw(get_canvas_item(), bg_rect)
		var capped_value: float = value

		if value > max_value:
			capped_value = max_value
			overflow = true
		elif value < min_value:
			capped_value = min_value
			underflow = true

		var display_origin: float = min_value
		var display_end: float = capped_value
		if mid_value is float:
			if value < mid_value:
				display_end = mid_value
				display_origin = capped_value
				style = negative_style
			else:
				display_origin = mid_value
				display_end = capped_value
		else:
			if value < min_value:
				display_origin = min_value
				display_end = min_value
			else:
				display_origin = min_value
				display_end = capped_value

		var inset_length = size.x - inset * 2
		var scale = inset_length / (max_value - min_value)
		var value_rect = Rect2(
			scale * (display_origin - min_value) - (size.x / 2),
			inset - (size.y / 2),
			scale * (display_end - min_value),
			size.y - inset *  2
		)
		
		normal_style.draw(get_canvas_item(), value_rect)
		
		if overflow:
			var centre = bg_rect.end - Vector2(10, size.y / 2)
			draw_circle(centre, 5, Color.BLACK, true)
			draw_circle(centre, 5, Color.WHITE, false)
		if underflow:
			var centre = bg_rect.position + Vector2(10, +size.y / 2)
			draw_circle(centre, 5, Color.BLACK, true)
			draw_circle(centre, 5, Color.WHITE, false)
	else:
		empty_value_style.draw(get_canvas_item(), bg_rect)
