class_name DiagramCanvas extends Node2D

var design: Design
# Diagram Content
var diagram_objects: Dictionary = {} # int -> Node2

@export var zoom_level: float = 1.0
@export var canvas_offset: Vector2 = Vector2.ZERO
@export var sync_needed: bool = true

const default_pictogram_color = Color.WHITE
const default_label_color = Color.WHITE
const default_selection_color: Color = Color(1.0,0.8,0)

signal selection_changed(selection: Selection)

# var objects: Dictionary = {} # int -> DesignObject
# var connections: Array[DiagramConnection] = []
# var nodes: Array[DiagramNode] = []

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

# Selection
var selection: Selection = Selection.new()

func _init():
	design = Design.global

func _ready():
	add_to_group("drag_drop_targets")
	selection.selection_changed.connect(_on_selection_changed)
	GlobalSimulator.simulation_step.connect(_on_simulation_step)
	Design.global.design_changed.connect(_on_design_changed)
	
func _on_simulation_step():
	for node in design.all_nodes():
		var diagram_node = get_diagram_node(node.object_id)
		# We might get null node when sync is queued and we do not have a canvas node yeta
		if diagram_node != null:
			diagram_node.update_from(node)
	
func _on_selection_changed(objects):
	selection_changed.emit(objects)

func _on_design_changed():
	sync_needed = true

func queue_sync():
	sync_needed = true

var is_dragging: bool = false

func _unhandled_input(event):
	if event is InputEventPanGesture:
		canvas_offset += (-event.delta) * zoom_level * 10
		update_canvas_position()
	elif event is InputEventMagnifyGesture:
		var mouse = get_global_mouse_position()
		var new_trans = transform.scaled(Vector2(event.factor, event.factor))
		var new_mouse = new_trans.affine_inverse() * mouse
		zoom_level *= event.factor
		# zoom_level = clamp(zoom_level, 0.1, 5.0)
		canvas_offset += (get_local_mouse_position() - new_mouse) * zoom_level
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
	
func _process(_delta):
	if sync_needed:
		sync_design()
		sync_needed = false
	
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

var counter: int = 0

func sync_design():
	sync_nodes()
	sync_edges()
	
func sync_nodes():
	# 1. Get existing model node solids
	var existing: Dictionary = {}
	
	for node in self.all_diagram_nodes():
		existing[node.object_id] = node

	# 2. Update all nodes that are in the graph
	for object in design.all_nodes():
		var node: DiagramNode = existing.get(object.object_id)
		if node != null:
			node.update_from(object)
			existing.erase(object.object_id)
		else:
			create_node_from(object)
	
	# 3. Remove all orphaned nodes
	for dead in existing.values():
		diagram_objects.erase(dead.object_id)
		dead.free()

func sync_edges():
	# 1. Get existing model connections
	var existing: Dictionary = {}
	
	for edge in self.all_diagram_connections():
		existing[edge.object_id] = edge

	# 2. Update all connections that are in the design
	for object in design.all_edges():
		var conn = existing.get(object.object_id)
		if conn != null:
			conn.update_from(object)
			existing.erase(object.object_id)
		else:
			create_edge_from(object)
	
	# 3. Remove all orphaned connections
	for dead in existing.values():
		diagram_objects.erase(dead.object_id)
		dead.free()

func create_node_from(object: DesignObject) -> DiagramNode:
	var node: DiagramNode = DiagramNode.new()
	node.name = "diagram_node" + str(object.object_id)
	node.type_name = object.type_name
	node.object_id = object.object_id
	diagram_objects[object.object_id] = node
	add_child(node)
	node.update_from(object)
	return node

func create_edge_from(object: DesignObject) -> DiagramConnection:
	if object.origin == null or object.target == null:
		push_error("Trying to create connection from object without origin or target")
		return
	var conn: DiagramConnection = DiagramConnection.new()
	var origin: DiagramNode = get_diagram_node(object.origin)
	var target: DiagramNode = get_diagram_node(object.target)
	if object.origin == null or object.target == null:
		push_error("Origin or target are not part of canvas")
		return
	conn.set_connection(origin, target)	
	conn.name = "diagram_connection" + str(object.object_id)
	conn.type_name = object.type_name
	conn.object_id = object.object_id
	diagram_objects[object.object_id] = conn
	add_child(conn)
	return conn

# Selection
# ----------------------------------------------------------------
func begin_drag_selection(_mouse_position: Vector2):
	for node in selection.objects:
		if node is DiagramNode:
			node.is_dragged = true

func drag_selection(move_delta: Vector2):
	for node in selection.objects:
		if node is DiagramNode:
			node.position += move_delta
			var object = design.get_object(node.object_id)
			object.set_attribute("position", node.position)
		elif node is DiagramConnection:
			# For now, do nothing (and let the reader of the source know)
			pass
		else:
			push_error("Trying to drag invalid node: ", node)

func finish_drag_selection(_final_position: Vector2) -> void:
	for node in selection.objects:
		if node is DiagramNode:
			node.is_dragged = false
			var object = design.get_object(node.object_id)
			object.set_attribute("position", node.position)
			# node.position = final_position
		
func delete_selection():
	for object in selection.objects:
		design.remove_object(object.object_id)

	selection.clear()
	queue_sync()

# Dragging
# ----------------------------------------------------------------


func _can_drop_data(position, data):
	print("Can drop at ", position, " Data: ", data)
	return false

func _drop_data(position, data):
	print("Will drop at ", position, " Data: ", data)

func _on_dragging_entered():
	print("DRAGGING ENTERED")
	pass
	
func _on_dragging_exited():
	print("DRAGGING EXITED")
	pass
	
func _on_dragging_updated():
	print("DRAGGING UPDATED")
	pass

func _on_dragging_ended():
	print("DRAGGING ENDED")
	pass

func _on_dragging_cancelled():
	print("DRAGGING CANCELLED")
	pass


func _accepts_drag_drop(item: Variant, position: Vector2) -> bool:
	return true

func _handle_drag_drop(item: Variant, position: Vector2):
	print("Item dropped:", item, "at", position)

func _drag_entered(item: Variant, position: Vector2):
	print("Drag entered:", item, "at", position)

func _drag_exited():
	print("Drag exited")
