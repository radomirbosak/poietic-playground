class_name ConnectTool extends CanvasTool

enum ConnectToolState {
	EMPTY, CONNECT
}

var state: ConnectToolState
var type_name: String = "Parameter"

var last_pointer_position = Vector2()
var origin: DiagramNode
var dragging_connector: Connector = null

func tool_name() -> String:
	return "connect"

func set_type(type_name: String):
	self.type_name = type_name
	
func tool_selected():
	object_panel.show()
	object_panel.load_connector_pictograms()
	if last_selected_object_identifier:
		object_panel.selected_item = last_selected_object_identifier
	else:
		object_panel.selected_item = "Flow"
	object_panel.selection_changed.connect(_on_object_selection_changed)

func tool_released():
	last_selected_object_identifier = object_panel.selected_item
	object_panel.selection_changed.disconnect(_on_object_selection_changed)

func _on_object_selection_changed(identifier: String):
	type_name = identifier

func input_began(_event: InputEvent, pointer_position: Vector2):
	var target = canvas.hit_target(pointer_position)
	if not target:
		return
	if target.type != DiagramCanvas.HitTargetType.OBJECT:
		return
		
	if target.object is DiagramNode:
		create_drag_connector(target.object, pointer_position)
		origin = target.object
		state = ConnectToolState.CONNECT
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	else:
		state = ConnectToolState.EMPTY
	
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	if state == ConnectToolState.CONNECT:
		dragging_connector.target_point += move_delta
		var target = canvas.hit_target(dragging_connector.target_point)
		if not target:
			return
		elif target.type != DiagramCanvas.HitTargetType.OBJECT:
			return
		elif target.object is DiagramNode:
			if can_connect(target.object):
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

			var target = canvas.hit_target(pointer_position)
			if not target:
				cancel_drag_connector()
			elif target.type != DiagramCanvas.HitTargetType.OBJECT:
				cancel_drag_connector()
			elif target.object is DiagramNode:
				if can_connect(target.object):
					create_connector(origin, target.object)
				else:
					# Do some "poofffffff" animation here
					pass
				cancel_drag_connector()
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

func cancel_drag_connector():
	dragging_connector.free()
	dragging_connector = null
	origin = null

func can_connect(target: DiagramNode) -> bool:
	if target == origin:
		return false
	else:
		return Global.design.can_connect(type_name, origin.object_id, target.object_id)


func create_connector(origin: DiagramNode, target: DiagramNode):
	var trans = Global.design.new_transaction()
	print("Create connector of type: ", type_name, " from: ", origin.object_id, " to: ", target.object_id)
	var edge = trans.create_edge(type_name, origin.object_id, target.object_id)
	print("Connector created: ", edge)
	Global.design.accept(trans)
