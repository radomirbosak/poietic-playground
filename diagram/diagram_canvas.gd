class_name DiagramCanvas extends Node2D

# TODO: Add error indicators at the canvas edges if there are objects with errors at that direction

var diagram_objects: Dictionary[int, Node2D] = {} 
var selection: PoieticSelection = PoieticSelection.new()

@export var zoom_level: float = 1.0
@export var canvas_offset: Vector2 = Vector2.ZERO
@export var _design_sync_needed: bool = true

const default_pictogram_color = Color.WHITE
const default_label_color = Color.WHITE
const default_selection_color: Color = Color(1.0,0.8,0)

func all_diagram_node_ids() -> PackedInt64Array:
	var result = PackedInt64Array()
	for object in diagram_objects.values():
		if object is DiagramNode:
			result.append(object.object_id)
	return result

func all_diagram_edge_ids() -> PackedInt64Array:
	var result = PackedInt64Array()
	for object in diagram_objects.values():
		if object is DiagramConnection:
			result.append(object.object_id)
	return result

func all_diagram_nodes() -> Array[DiagramNode]:
	var result: Array[DiagramNode]
	for object in diagram_objects.values():
		if object is DiagramNode:
			result.append(object)
	return result

func all_diagram_connections() -> Array[DiagramConnection]:
	var result: Array[DiagramConnection]
	for object in diagram_objects.values():
		if object is DiagramConnection:
			result.append(object)
	return result

func get_diagram_node(id: int) -> DiagramNode:
	var object = diagram_objects.get(id)
	if object is DiagramNode:
		return object
	else:
		return null

func get_diagram_connection(id: int) -> DiagramConnection:
	var object = diagram_objects.get(id)
	if object is DiagramConnection:
		return object
	else:
		return null


func _init():
	pass

func _ready():
	add_to_group("drag_drop_targets")
	selection.selection_changed.connect(_on_selection_changed)

func _process(_delta):
	if _design_sync_needed:
		sync_design()

func _on_selection_changed(objects):
	sync_selection()

func queue_sync():
	_design_sync_needed = true

## Update indicators from the player.
##
## This method is typically called on simulation player step.
func update_indicator_values():
	for id in Global.design.get_diagram_nodes():
		var object = Global.design.get_object(id)
		var diagram_node = get_diagram_node(id)
		# We might get null node when sync is queued and we do not have a canvas node yet
		if diagram_node:
			diagram_node.display_value = Global.player.numeric_value(id)

## Remove values from indicators
##
## This method is called when design fails validation or when the simulation fails.
##
func clear_indicators():
	for node in self.all_diagram_nodes():
		node.display_value = null

## Synchronize indicators based on a simulation result.
##
## The method sets initial value of indicators and sets indicator range from the
## simulation result (time series).
##
## This method is typically called on design change.
##
func sync_indicators(result: PoieticResult):
	for id in Global.design.get_diagram_nodes():
		var object = Global.design.get_object(id)
		var diagram_node = get_diagram_node(id)
		# We might get null node when sync is queued and we do not have a canvas node yet
		if diagram_node:
			var series = result.time_series(id)
			if not series:
				push_warning("No result time series for object ", id)
				continue
			diagram_node.value_indicator.min_value = series.data_min
			diagram_node.value_indicator.max_value = series.data_max
			if series.data_min < 0:
				diagram_node.value_indicator.mid_value = 0
			else:
				diagram_node.value_indicator.mid_value = null
			diagram_node.display_value = series.first
				
	
func _unhandled_input(event):
	if event is InputEventPanGesture:
		canvas_offset += (-event.delta) * zoom_level * 10
		update_canvas_position()
	elif event is InputEventMagnifyGesture:
		var g_mouse = get_global_mouse_position()
		var t_before = Transform2D().scaled(Vector2(zoom_level, zoom_level)).translated(canvas_offset)
		var m_before = t_before.affine_inverse() * g_mouse

		zoom_level *= event.factor
		zoom_level = clamp(zoom_level, 0.1, 5.0)

		var t_after = Transform2D().scaled(Vector2(zoom_level, zoom_level)).translated(canvas_offset)
		var m_after = t_after.affine_inverse() * g_mouse
		canvas_offset += -(m_before - m_after) * zoom_level
		update_canvas_position()
	else: # Regular tool use
		var tool = Global.current_tool
		if not tool:
			return
		tool.canvas = self
		if tool.handle_intput(event):
			get_viewport().set_input_as_handled()

func update_canvas_position() -> void:
	self.position = canvas_offset
	self.scale = Vector2(zoom_level, zoom_level)
	
func object_at_position(test_position: Vector2):
	for child in get_children():
		if child is DiagramNode:
			if child.contains_point(test_position):
				return child
		elif child is DiagramConnection:
			if child.contains_point(test_position):
				return child
			
	return null

func get_connections(node: DiagramNode) -> Array[DiagramConnection]:
	var children: Array[DiagramConnection] = []
	for conn in all_diagram_connections():
		if conn.origin == node or conn.target == node:
			children.append(conn)
	return children

func sync_design():
	var diff = Global.design.get_difference(all_diagram_node_ids(), all_diagram_edge_ids())
	
	# We need to remove both nodes and edges first, just in case the design contains objects where
	# structure type has changed. Same ID, previously Node, now Edge.
	for id in diff.removed_nodes:
		var object = diagram_objects[id]
		diagram_objects.erase(id)
		object.queue_free()
		
	for id in diff.removed_edges:
		var object = diagram_objects[id]
		diagram_objects.erase(id)
		object.queue_free()

	# Current Nodes
	for node in all_diagram_nodes():
		var object: PoieticObject = Global.design.get_object(node.object_id)
		node.update_from(object)
		var issues = Global.design.issues_for_object(node.object_id)
		node.has_errors = !issues.is_empty()

	# Added Nodes
	for id in diff.added_nodes:
		var object: PoieticObject = Global.design.get_object(id)
		var node = create_node_from(object)
		var issues = Global.design.issues_for_object(id)
		node.has_errors = !issues.is_empty()

	# Current edges
	for conn in all_diagram_connections():
		var object: PoieticObject = Global.design.get_object(conn.object_id)
		
		var origin: DiagramNode = get_diagram_node(object.origin)
		assert(origin)
		conn.origin = origin
		var target: DiagramNode = get_diagram_node(object.target)
		assert(target)
		conn.target = target

		conn.update_from(object)
		var issues = Global.design.issues_for_object(conn.object_id)
		conn.has_errors = !issues.is_empty()
	
	# Added Edges
	for id in diff.added_edges:
		var object: PoieticObject = Global.design.get_object(id)
		var new_conn = create_edge_from(object)
		assert(new_conn)
		var issues = Global.design.issues_for_object(id)
		new_conn.has_errors = !issues.is_empty()

	# Finalize
	sync_selection()
	_design_sync_needed = false

func sync_selection():
	var selected_ids = selection.get_ids()
	for child in self.get_children():
		if child is DiagramNode:
			child.set_selected(selected_ids.has(child.object_id))
		elif child is DiagramConnection:
			child.set_selected(selected_ids.has(child.object_id))
	
		
func create_node_from(object: PoieticObject) -> DiagramNode:
	var node: DiagramNode = DiagramNode.new()
	node.name = "diagram_node" + str(object.object_id)
	node.type_name = object.type_name
	node.object_id = object.object_id

	diagram_objects[object.object_id] = node
	add_child(node)
	node.update_from(object)
	return node

func create_edge_from(object: PoieticObject) -> DiagramConnection:
	if object.origin == null or object.target == null:
		push_error("Trying to create connection from object without origin or target.")
		return null
	var origin: DiagramNode = get_diagram_node(object.origin)
	var target: DiagramNode = get_diagram_node(object.target)

	if origin == null:
		# This might be because we are trying to create a non-diagram connection.
		push_error("Origin ", object.origin, " is not part of canvas. Connection not created.")
		return null
	if target == null:
		# This might be because we are trying to create a non-diagram connection.
		push_error("Target ", object.target, " is not part of canvas. Connection not created.")
		return null

	var conn: DiagramConnection = DiagramConnection.new()
	conn.set_connection(origin, target)	
	conn.name = "diagram_connection" + str(object.object_id)
	conn.type_name = object.type_name
	conn.object_id = object.object_id
	diagram_objects[object.object_id] = conn
	add_child(conn)
	return conn

# Selection
# ----------------------------------------------------------------
func get_selected_nodes() -> Array[DiagramNode]:
	var result: Array[DiagramNode] = []
	for id in selection.get_ids():
		var node = self.get_diagram_node(id)
		if node:
			result.append(node)
	return result

func begin_drag_selection(_mouse_position: Vector2):
	for node in get_selected_nodes():
		node.is_dragged = true

func drag_selection(move_delta: Vector2):
	for node in get_selected_nodes():
		node.position += move_delta

func finish_drag_selection(_final_position: Vector2) -> void:
	var trans = Global.design.new_transaction()
	
	for node in get_selected_nodes():
		node.is_dragged = false
		var object = Global.design.get_object(node.object_id)
		trans.set_attribute(node.object_id, "position", node.position)
	# TODO: Send signal that frame has been changed
	Global.design.accept(trans)
	# FIXME: Proper change handling
		
func delete_selection():
	var trans = Global.design.new_transaction()

	for id in selection.get_ids():
		trans.remove_object(id)

	Global.design.accept(trans)

	selection.clear()
	queue_sync()
