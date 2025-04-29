class_name PanTool extends CanvasTool

enum PanToolState {
	IDLE,
	PANNING
}

var state: PanToolState = PanToolState.IDLE
var start_canvas_offset: Vector2 = Vector2.ZERO
var previous_position: Vector2 = Vector2.ZERO

func tool_name() -> String:
	return "pan"

func tool_selected():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func tool_released():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func input_began(event: InputEvent, pointer_position: Vector2) -> bool:
	if event.button_index == MOUSE_BUTTON_LEFT:
		start_canvas_offset = canvas.canvas_offset
		previous_position = pointer_position
		state = PanToolState.PANNING
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		return true
	return false

func input_moved(event: InputEvent, move_delta: Vector2) -> bool:
	if state == PanToolState.PANNING:
		previous_position = previous_position + move_delta
		canvas.canvas_offset += move_delta * canvas.zoom_level
		canvas.update_canvas_view()
		return true
	return false

func input_ended(_event: InputEvent, pointer_position: Vector2) -> bool:
	if state == PanToolState.PANNING:
		canvas.canvas_offset += (pointer_position - previous_position) * canvas.zoom_level
		canvas.update_canvas_view()
		state = PanToolState.IDLE
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		return true
	return false

func input_cancelled(_event: InputEvent) -> bool:
	if state == PanToolState.PANNING:
		# Reset to original position if cancelled
		canvas.canvas_offset = start_canvas_offset
		state = PanToolState.IDLE
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		return true
	return false
