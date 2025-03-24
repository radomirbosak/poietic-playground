class_name SelectionTool extends CanvasTool

var last_pointer_position = Vector2()
enum SelectToolState {
	EMPTY, OBJECT_HIT, OBJECT_SELECT, OBJECT_MOVE, HANDLE_HIT, HANDLE_MOVE
}
var state: SelectToolState = SelectToolState.EMPTY

var dragging_handle: Handle = null

func tool_name() -> String:
	return "select"
	
func input_began(event: InputEvent, pointer_position: Vector2) -> bool:
	var candidate = canvas.object_at_position(pointer_position)
	if candidate is DiagramObject:
		if event.shift_pressed:
			canvas.selection.toggle(candidate.object_id)
		else:
			if canvas.selection.is_empty() or !canvas.selection.contains(candidate.object_id):
				canvas.selection.replace(PackedInt64Array([candidate.object_id]))
			else:
				print("Context menu now? (not implemented)")

		last_pointer_position = pointer_position
		state = SelectToolState.OBJECT_HIT
		return true
	elif candidate is Handle:
		state = SelectToolState.HANDLE_HIT
		dragging_handle = candidate
		return true
	else:
		canvas.selection.clear()
		state = SelectToolState.OBJECT_SELECT
		return true
		# TODO: Initiate rubber band here

func input_moved(event: InputEvent, move_delta: Vector2) -> bool:
	var mouse_position = event.global_position
	last_pointer_position += move_delta
	match state:
		SelectToolState.OBJECT_SELECT:
			pass
		SelectToolState.OBJECT_HIT:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			canvas.begin_drag_selection(mouse_position)
			state = SelectToolState.OBJECT_MOVE
		SelectToolState.OBJECT_MOVE:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			canvas.drag_selection(move_delta)
		SelectToolState.HANDLE_HIT:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			canvas.begin_drag_handle(dragging_handle, mouse_position)
			state = SelectToolState.HANDLE_MOVE
		SelectToolState.HANDLE_MOVE:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			canvas.drag_handle(dragging_handle, move_delta)
	return true
	
func input_ended(_event: InputEvent, mouse_position: Vector2) -> bool:
	match state:
		SelectToolState.OBJECT_SELECT:
			pass
		SelectToolState.OBJECT_HIT:
			pass
		SelectToolState.OBJECT_MOVE:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			canvas.finish_drag_selection(mouse_position)
		SelectToolState.HANDLE_MOVE:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			canvas.finish_drag_handle(dragging_handle, mouse_position)
			dragging_handle = null

	state = SelectToolState.EMPTY
	return true
