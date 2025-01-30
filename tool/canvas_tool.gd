class_name CanvasTool extends Node

var canvas: DiagramCanvas

var initial_pointer_position: Vector2 = Vector2()

func tool_name() -> String:
	return "default"

func handle_intput(event: InputEvent):
	if event is InputEventMouseButton:
		var mouse_position = event.global_position
		if event.is_pressed():
			initial_pointer_position = mouse_position
			input_began(event, mouse_position)
		elif event.is_released():
			input_ended(event, mouse_position)
			initial_pointer_position = Vector2()
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT:
		input_moved(event, event.relative / canvas.zoom_level)
	elif event.is_canceled():
		input_cancelled(event)
		initial_pointer_position = Vector2()

func input_began(_event: InputEvent, _pointer_position: Vector2):
	pass
	
func input_ended(_event: InputEvent, _pointer_position: Vector2):
	pass
	
func input_moved(_event: InputEvent, _move_delta: Vector2):
	pass
	
func input_cancelled(_event: InputEvent):
	pass
