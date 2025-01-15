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
	print("initiate connect")
	var candidate = canvas.object_at_position(pointer_position)
	if candidate != null:
		create_drag_connection(candidate, pointer_position)
		state = ConnectToolState.CONNECT
		print("Connect initiated at ", candidate)
	else:
		print("Empty connect click")
		state = ConnectToolState.EMPTY
	
func input_ended(event: InputEvent, pointer_position: Vector2):
	print("Conclude connect")
	if dragging_connection == null:
		push_error("Concluding connection without connection node")
		return
	state = ConnectToolState.EMPTY
	dragging_target.free()

	var target = canvas.object_at_position(pointer_position)
	if target != null:
		canvas.add_connection(dragging_connection.origin, target)
	dragging_connection.free()
	dragging_connection = null
	
func input_moved(event: InputEvent, move_delta: Vector2):
	if state == ConnectToolState.CONNECT:
		print("Connect to: ", event.position)
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
