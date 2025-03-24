class_name Circle2D extends Node2D

var center: Vector2 = Vector2()
var radius: float = 10.0
var color: Color = Color.WHITE
var fill_color: Color = Color.WHITE
var width: float = -1
var filled: bool = false

func _draw() -> void:
	if filled:
		draw_circle(center, radius, fill_color, true, width)
	draw_circle(center, radius, color, false, width)
