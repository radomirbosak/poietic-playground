class_name CanvasTool extends Node

var canvas: DiagramCanvas
var initial_pointer_position: Vector2 = Vector2()
var is_engaged: bool = false

func tool_name() -> String:
	return "default"

func handle_intput(event: InputEvent) -> bool:
	var is_consumed: bool = false
	if event is InputEventMouseButton:
		var mouse_position = event.global_position
		if event.is_pressed():
			initial_pointer_position = mouse_position
			is_consumed = input_began(event, mouse_position)
		elif event.is_released():
			is_consumed = input_ended(event, mouse_position)
			initial_pointer_position = Vector2()
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT:
		is_consumed = input_moved(event, event.relative / canvas.zoom_level)
	elif event.is_canceled():
		is_consumed = input_cancelled(event)
		initial_pointer_position = Vector2()
	return is_consumed

func tool_selected():
	pass

func input_began(_event: InputEvent, _pointer_position: Vector2) -> bool:
	return false
	
func input_ended(_event: InputEvent, _pointer_position: Vector2) -> bool:
	return false
	
func input_moved(_event: InputEvent, _move_delta: Vector2) -> bool:
	return false
	
func input_cancelled(_event: InputEvent) -> bool:
	return false

## Release the tool.
## Called when another tools is selected.
func tool_released():
	pass
