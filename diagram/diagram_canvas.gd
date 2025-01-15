extends Node2D


# Diagram Content
var connections: Array[DiagramConnection] = []
var nodes: Array[DiagramNode] = []

var selected_objects: Array[DiagramNode] = []

var pan_speed = 0          # Current speed of panning
var max_speed = 2000       # Maximum speed
var acceleration = 400     # Acceleration rate
var deceleration = 600     # Deceleration rate
var velocity = Vector2.ZERO  # Current velocity of the camera


# Connector tool
var dragging_connection: DiagramConnection = null
var dragging_target: Node2D = null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		if not child is DiagramNode:
			continue
		if child.has_point(test_position):
			return child
			
	return null

var is_dragging = false
var drag_position = Vector2()
enum SelectToolState {
	EMPTY, HIT, SELECT, MOVE
}
var select_tool_state: SelectToolState = SelectToolState.EMPTY
	
# Click on empty
# Click on node
	
	
func _input(event):
	if Global.current_tool == Global.Tool.SELECT:
		handle_select_input(event)
	elif  Global.current_tool == Global.Tool.CONNECT:
		handle_connect_input(event)

func handle_select_input(event):
	if event is InputEventMouseButton:
		# BEGIN
		if event.is_pressed():
			var mouse_position = get_viewport().get_mouse_position()
			print("Click at ", event.position, " mouse at ", mouse_position)
			var candidate = object_at_position(mouse_position)
			if candidate:
				if event.shift_pressed:
					var index = selected_objects.find(candidate)
					if index == -1:
						candidate.set_selected(true)
						selected_objects.append(candidate)
					else:
						candidate.set_selected(false)
						selected_objects.remove_at(index)
				else:
					if selected_objects.is_empty():
						candidate.set_selected(true)
						selected_objects = [candidate]
					else:
						var index = selected_objects.find(candidate)
						if index == -1:
							clear_selection()
							candidate.set_selected(true)
							selected_objects = [candidate]
						else:
							pass

				print("Selection size ", len(selected_objects))
				drag_position = mouse_position
				select_tool_state = SelectToolState.HIT
			else:
				print("will select")
				selected_objects = []
				select_tool_state = SelectToolState.SELECT
				# Initiate rubber band
		elif event.is_released():
			match select_tool_state:
				SelectToolState.HIT, SelectToolState.SELECT:
					print("Conclude select")
					for node in nodes:
						node.set_selected(selected_objects.has(node))
				SelectToolState.MOVE:
					pass
				_:
					push_error("Invalid selection tool state: ", select_tool_state)
			select_tool_state = SelectToolState.EMPTY

	if event is InputEventMouseMotion:
		match select_tool_state:
			SelectToolState.SELECT:
				pass
			SelectToolState.HIT, SelectToolState.MOVE:
				var move_delta = event.position - drag_position
				move_selection(move_delta)
				drag_position = event.position
				select_tool_state == SelectToolState.MOVE

func clear_selection():
	for node in selected_objects:
		node.set_selected(false)


func move_selection(delta: Vector2):
	print("Move selection of ", len(selected_objects))
	for node in selected_objects:
		var new_position = node.position + delta
		move_diagram_node(node, new_position)


func handle_connect_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed():
			print("initiate connect")
			var mouse_position = get_viewport().get_mouse_position()
			var selection = object_at_position(mouse_position)
			if selection != null:
				create_drag_connection(selection)
				is_dragging = true
				print("Connect initiated at ", selection)
			else:
				print("Empty connect click")
				is_dragging = false
		elif event.is_released():
			print("Conclude connect")
			if dragging_connection == null:
				push_error("Concluding connection without connection node")
				return
			is_dragging = false
			dragging_target.free()

			var mouse_position = get_viewport().get_mouse_position()
			var target = object_at_position(mouse_position)
			if target != null:
				add_connection(dragging_connection.origin, target)
			dragging_connection.free()
			dragging_connection = null
				
	elif event is InputEventMouseMotion and is_dragging:
		print("Connect to: ", event.position)
		var mouse_position = get_viewport().get_mouse_position()
		dragging_target.position = dragging_target.get_parent().to_local(mouse_position)
		dragging_connection.update_shape()

func get_connections(node: DiagramNode) -> Array[DiagramConnection]:
	var children: Array[DiagramConnection] = []
	for conn in connections:
		if conn.origin == node or conn.target == node:
			children.append(conn)
	return children

func move_diagram_node(node: DiagramNode, new_position: Vector2):
	node.position = new_position
	for connection in get_connections(node):
		connection.update_shape()

func create_drag_connection(origin):
	if dragging_connection != null:
		push_error("Creating drag connection when one already exists")
	dragging_connection = DiagramConnection.new()
	dragging_target = Node2D.new()
	add_child(dragging_connection)
	add_child(dragging_target)
	dragging_target.position = origin.position
	dragging_connection.set_connection(origin, dragging_target)
	
	dragging_connection.update_shape()

var counter: int = 0

func add_node(new_position: Vector2) -> DiagramNode:
	var node: DiagramNode = DiagramNode.new()
	counter += 1
	node.name = "diagram_node" + str(counter)
	node.set_position(new_position)
	add_child(node)
	nodes.append(node)
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
