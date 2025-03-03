class_name SelectionTool extends CanvasTool

var last_pointer_position = Vector2()

enum SelectToolState {
	EMPTY, HIT, SELECT, MOVE
}
var state: SelectToolState = SelectToolState.EMPTY

func tool_name() -> String:
	return "select"
	
func input_began(event: InputEvent, pointer_position: Vector2) -> bool:
	var candidate = canvas.object_at_position(pointer_position)
	if candidate:
		if event.shift_pressed:
			canvas.selection.toggle(candidate.object_id)
		else:
			if canvas.selection.is_empty() or !canvas.selection.contains(candidate.object_id):
				canvas.selection.replace(PackedInt64Array([candidate.object_id]))
			else:
				print("Context menu now? (not implemented)")

		last_pointer_position = pointer_position
		state = SelectToolState.HIT
		return true
	else:
		canvas.selection.clear()
		state = SelectToolState.SELECT
		return true
		# TODO: Initiate rubber band here

func input_moved(event: InputEvent, move_delta: Vector2) -> bool:
	var mouse_position = event.global_position
	last_pointer_position += move_delta
	match state:
		SelectToolState.SELECT:
			pass
		SelectToolState.HIT:
			canvas.begin_drag_selection(mouse_position)
			state = SelectToolState.MOVE
		SelectToolState.MOVE:
			canvas.drag_selection(move_delta)
	return true
	
func input_ended(_event: InputEvent, mouse_position: Vector2) -> bool:
	match state:
		SelectToolState.SELECT:
			pass
		SelectToolState.HIT:
			pass
		SelectToolState.MOVE:
			canvas.finish_drag_selection(mouse_position)

	state = SelectToolState.EMPTY
	return true
