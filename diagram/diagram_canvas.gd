class_name DiagramCanvas extends Node2D

const default_pictogram_color = Color(1.0,0.8,0)
const default_label_color = Color(1.0,0.8,0)
const default_selection_color: Color = Color.WHITE

signal selection_changed(selection: Selection)

# Diagram Content
var connections: Array[DiagramConnection] = []
var nodes: Array[DiagramNode] = []

# Selection
var selection: Selection = Selection.new()

# Panning
var pan_speed = 0          # Current speed of panning
var max_speed = 2000       # Maximum speed
var acceleration = 400     # Acceleration rate
var deceleration = 600     # Deceleration rate
var velocity = Vector2.ZERO  # Current velocity of the camera

func _ready():
	selection.selection_changed.connect(_on_selection_changed)
	
func _exit_tree():
	pass
	
func _on_selection_changed(objects):
	selection_changed.emit(objects)

func _unhandled_input(event):
	var tool = Global.current_tool
	if tool != null:
		tool.canvas = self
		tool.handle_intput(event)

func _process(delta):
	var direction = Vector2.ZERO
	# Check input for panning directions
	if Input.is_action_pressed("pan-left"):
		direction.x += 1
	if Input.is_action_pressed("pan-right"):
		direction.x -= 1
	if Input.is_action_pressed("pan-up"):
		direction.y += 1
	if Input.is_action_pressed("pan-down"):
		direction.y -= 1
	
	# Normalize direction vector to ensure uniform movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		# Accelerate while holding keys
		velocity += direction * acceleration * delta
		# Clamp velocity to maximum speed
		velocity = velocity.limit_length(max_speed)
	else:
		# Decelerate if no keys are pressed
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	# Update camera position based on velocity
	position += velocity * delta
	
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
	for conn in connections:
		if conn.origin == node or conn.target == node:
			children.append(conn)
	return children

var counter: int = 0

func create_node(type_name: String, new_position: Vector2, label: String) -> DiagramNode:
	var node: DiagramNode = DiagramNode.new()
	counter += 1
	node.name = "diagram_node" + str(counter)
	node.type_name = type_name
	node.position = new_position
	node.label = label
	nodes.append(node)
	add_child(node)
	return node

func add_connection(origin: DiagramNode, target: DiagramNode):
	if origin == null or target == null:
		push_error("Trying to add a connection without origin or target")
		return
	var conn = DiagramConnection.new()
	counter += 1
	conn.name = "diagram_connection" + str(counter)
	add_child(conn)
	conn.set_connection(origin, target)	
	connections.append(conn)

# Selection
# ----------------------------------------------------------------
func begin_drag_selection(mouse_position: Vector2):
	for node in selection.objects:
		if node is DiagramNode:
			node.is_dragged = true

func drag_selection(move_delta: Vector2):
	for node in selection.objects:
		if node is DiagramNode:
			node.position += move_delta
		elif node is DiagramConnection:
			# For now, do nothing (and let the reader of the source know)
			pass
		else:
			push_error("Trying to drag invalid node: ", node)

func finish_drag_selection(final_position: Vector2) -> void:
	for node in selection.objects:
		if node is DiagramNode:
			node.is_dragged = false
			# node.position = final_position
		
func delete_selection():
	for object in selection.objects:
		if object is DiagramNode:
			delete_node(object)
		elif object is DiagramConnection:
			delete_connection(object)
		else:
			push_error("Trying to delete unknown object: ", object)

	selection.clear()

func delete_node(node: DiagramNode):
	var conns = get_connections(node)
	for conn in conns:
		var index = connections.find(conn)
		assert(index != -1)
		connections.remove_at(index)
		conn.free()

	var index = nodes.find(node)
	assert(index != -1)
	nodes.remove_at(index)
	node.free()

func delete_connection(connection: DiagramConnection):
	var index = connections.find(connection)
	assert(index != -1)
	connections.remove_at(index)
	connection.free()
