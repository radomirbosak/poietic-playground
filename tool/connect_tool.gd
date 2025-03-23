class_name ConnectTool extends CanvasTool

enum ConnectToolState {
	EMPTY, CONNECT
}

var state: ConnectToolState

var last_pointer_position = Vector2()

var origin: DiagramNode

var dragging_connector: Connector = null

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
		create_drag_connector(candidate, pointer_position)
		origin = candidate
		state = ConnectToolState.CONNECT
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	else:
		state = ConnectToolState.EMPTY
	
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	if state == ConnectToolState.CONNECT:
		dragging_connector.target_point += move_delta
		var target = canvas.object_at_position(dragging_connector.target_point)
		if target and target is DiagramNode:
			if can_connect(target):
				Input.set_default_cursor_shape(Input.CURSOR_CAN_DROP)
			else:
				Input.set_default_cursor_shape(Input.CURSOR_FORBIDDEN)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	
func input_ended(_event: InputEvent, pointer_position: Vector2):
	match state:
		ConnectToolState.EMPTY:
			pass
		ConnectToolState.CONNECT:
			assert(dragging_connector != null)
			state = ConnectToolState.EMPTY

			var target = canvas.object_at_position(pointer_position)
			if target is DiagramNode:
				if can_connect(target):
					create_connector(origin, target)
				else:
					# Do some "poofffffff" animation here
					pass
			dragging_connector.free()
			dragging_connector = null
			origin = null
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func create_drag_connector(origin: DiagramNode, pointer_position: Vector2):
	print("Creating drag connector of type ", type_name)
	assert(canvas != null)
	assert(dragging_connector == null)
	
	dragging_connector = DiagramConnector.create_connector(type_name)
	canvas.add_child(dragging_connector)
	dragging_connector.target_point = canvas.to_local(pointer_position)
	# TODO: Clip at origin border
	dragging_connector.origin_point = origin.position

func can_connect(target: DiagramNode) -> bool:
	if target == origin:
		return false
	else:
		return Global.design.can_connect(type_name, origin.object_id, target.object_id)


func create_connector(origin: DiagramNode, target: DiagramNode):
	if !Global.metamodel.has_type(type_name):
		push_error("Unknown connector type: ", type_name)
		return
	var trans = Global.design.new_transaction()
	print("Create connector of type: ", type_name, " from: ", origin.object_id, " to: ", target.object_id)
	var edge = trans.create_edge(type_name, origin.object_id, target.object_id)
	print("Connector created: ", edge)
	Global.design.accept(trans)
