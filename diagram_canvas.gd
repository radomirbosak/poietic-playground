extends Node2D

var selected_objects = []

var pan_speed = 0          # Current speed of panning
var max_speed = 2000       # Maximum speed
var acceleration = 400     # Acceleration rate
var deceleration = 600     # Deceleration rate
var velocity = Vector2.ZERO  # Current velocity of the camera

# Content
var connections: Array[DiagramConnection] = []

# Connector tool
var dragging_connection: DiagramConnection = null
var dragging_target: Node2D = null
	
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Diagram ready")
	pass # Replace with function body.

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

func _input(event):
	if Global.current_tool == Global.Tool.SELECT:
		handle_select_input(event)
	elif  Global.current_tool == Global.Tool.CONNECT:
		handle_connect_input(event)

func handle_select_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			var mouse_position = get_viewport().get_mouse_position()
			print("Click at ", event.position, " mouse at ", mouse_position)
			var new_selection = object_at_position(mouse_position)
			if new_selection:
				selected_objects = [new_selection]
				print("Got ", new_selection)
				is_dragging = true
				drag_position = mouse_position
			else:
				selected_objects = []
				is_dragging = false
		elif event.is_released():
			print("Conclude move")
			is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		var move_delta = event.position - drag_position
		for object in selected_objects:
			move_diagram_node(object, object.position + move_delta)
		drag_position = event.position


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

func add_node(new_position: Vector2) -> DiagramNode:
	var node: DiagramNode = DiagramNode.new()
	node.set_position(new_position)
	add_child(node)
	return node

func add_connection(origin: DiagramNode, target: DiagramNode):
	if origin == null or target == null:
		push_error("Trying to add a connection without origin or target")
		return
	var conn = DiagramConnection.new()
	conn.name = "diagram_connection"
	add_child(conn)
	conn.set_connection(origin, target)	
	connections.append(conn)
