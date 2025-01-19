class_name ConnectTool extends CanvasTool

enum ConnectToolState {
	EMPTY, CONNECT
}

var state: ConnectToolState

var last_pointer_position = Vector2()

var dragging_connection: DiagramConnection = null
var dragging_target: Node2D = null

func tool_name() -> String:
	return "connect"

func input_began(event: InputEvent, pointer_position: Vector2):
	var candidate = canvas.object_at_position(pointer_position)
	if candidate is DiagramNode:
		create_drag_connection(candidate, pointer_position)
		state = ConnectToolState.CONNECT
	else:
		state = ConnectToolState.EMPTY
	
func input_ended(event: InputEvent, pointer_position: Vector2):
	match state:
		ConnectToolState.EMPTY:
			pass
		ConnectToolState.CONNECT:
			assert(dragging_connection != null)
			state = ConnectToolState.EMPTY
			dragging_target.free()

			var target = canvas.object_at_position(pointer_position)
			if target is DiagramNode:
				canvas.add_connection(dragging_connection.origin, target)
			else:
				print("Concluded with target: ", target)
			dragging_connection.free()
			dragging_connection = null
	
func input_moved(event: InputEvent, move_delta: Vector2):
	if state == ConnectToolState.CONNECT:
		dragging_target.position += move_delta
		dragging_connection.update_shape()
	
func create_drag_connection(origin: DiagramNode, pointer_position: Vector2):
	assert(canvas != null)
	assert(dragging_connection == null)

	dragging_connection = DiagramConnection.new()
	dragging_target = Node2D.new()
	canvas.add_child(dragging_connection)
	canvas.add_child(dragging_target)
	dragging_target.position = pointer_position
	dragging_connection.set_connection(origin, dragging_target)
	
	dragging_connection.update_shape()
