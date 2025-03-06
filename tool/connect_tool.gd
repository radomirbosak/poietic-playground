class_name ConnectTool extends CanvasTool

enum ConnectToolState {
	EMPTY, CONNECT
}

var state: ConnectToolState

var last_pointer_position = Vector2()

var origin: DiagramNode

var dragging_connection: DiagramConnection = null
var dragging_target: Node2D = null

var modal = 10
var palette: ObjectPalette
var type_name: String = "Parameter"

func tool_name() -> String:
	return "connect"

func set_type(type_name: String):
	self.type_name = type_name
	

func tool_selected():
	if not palette:
		palette = ObjectPalette.new()
		palette.point_side = CallOut.PointSide.LEFT
	
func tool_released():
	pass


func input_began(_event: InputEvent, pointer_position: Vector2):
	var candidate = canvas.object_at_position(pointer_position)
	if candidate is DiagramNode:
		create_drag_connection(candidate, pointer_position)
		origin = candidate
		state = ConnectToolState.CONNECT
	else:
		state = ConnectToolState.EMPTY
	
func input_ended(_event: InputEvent, pointer_position: Vector2):
	match state:
		ConnectToolState.EMPTY:
			pass
		ConnectToolState.CONNECT:
			assert(dragging_connection != null)
			state = ConnectToolState.EMPTY
			dragging_target.free()

			var target = canvas.object_at_position(pointer_position)
			if target is DiagramNode:
				create_connection(origin, target)
			dragging_connection.free()
			dragging_connection = null
			origin = null
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	if state == ConnectToolState.CONNECT:
		dragging_target.position += move_delta
		dragging_connection.update_arrow()
	
func create_drag_connection(origin: DiagramNode, pointer_position: Vector2):
	print("Drag connection of type ", type_name)
	assert(canvas != null)
	assert(dragging_connection == null)

	dragging_connection = DiagramConnection.new()
	dragging_target = Node2D.new()
	canvas.add_child(dragging_connection)
	canvas.add_child(dragging_target)
	dragging_target.position = canvas.to_local(pointer_position)
	dragging_connection.set_connection(origin, dragging_target)
	dragging_connection.type_name = type_name
	dragging_connection.update_arrow()


func create_connection(origin: DiagramNode, target: DiagramNode):
	if !Global.metamodel.has_type(type_name):
		push_error("Unknown connection type: ", type_name)
		return
	var trans = Global.design.new_transaction()
	print("Create connection of type: ", type_name, " from: ", origin.object_id, " to: ", target.object_id)
	var edge = trans.create_edge(type_name, origin.object_id, target.object_id)
	print("Connection created: ", edge)
	Global.design.accept(trans)
