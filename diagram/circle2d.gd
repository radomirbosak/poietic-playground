class_name Circle2D extends Node2D

var center := Vector2()
var radius := 0.0
var color := Color()
var width := 2

func _draw() -> void:
	draw_circle(center, radius, color, false, width)
