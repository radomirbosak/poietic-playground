class_name SelectionTool extends CanvasTool

var last_pointer_position = Vector2()

enum SelectToolState {
	EMPTY, HIT, SELECT, MOVE
}
var state: SelectToolState = SelectToolState.EMPTY

func tool_name() -> String:
	return "select"
	
func input_began(event: InputEvent, pointer_position: Vector2):
	var candidate = canvas.object_at_position(pointer_position)
	if candidate:
		if event.shift_pressed:
			canvas.selection.toggle(candidate)
		else:
			if canvas.selection.is_empty() or !canvas.selection.contains(candidate):
				canvas.selection.replace([candidate])
			else:
				print("Context menu now? (not implemented)")

		last_pointer_position = pointer_position
		state = SelectToolState.HIT
	else:
		canvas.selection.clear()
		state = SelectToolState.SELECT
		# TODO: Initiate rubber band here

func input_moved(event: InputEvent, move_delta: Vector2):
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

func input_ended(_event: InputEvent, mouse_position: Vector2):
	state = SelectToolState.EMPTY
	canvas.finish_drag_selection(mouse_position)

func input_cancelled(_event: InputEvent):
	pass
