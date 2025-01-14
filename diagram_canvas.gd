extends Node2D

var selected_objects = []

var pan_speed = 0          # Current speed of panning
var max_speed = 2000       # Maximum speed
var acceleration = 400     # Acceleration rate
var deceleration = 600     # Deceleration rate
var velocity = Vector2.ZERO  # Current velocity of the camera

# Connector tool
var current_connector: Node2D = null
var connector_origin: Node2D = null

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
	
	

func object_at_position(position: Vector2):
	for child in get_children():
		if not child is DiagramNode:
			continue
		var child_pos = child.get_global_transform().basis_xform(child.position)
		if child.has_point(position):
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
		if event.is_action_pressed("click"):
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
		elif event.is_action_released("click"):
			print("RELEASE")
			is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		
		print("Move to: ", event.position)
		var move_delta = event.position - drag_position
		for object in selected_objects:
			object.position += move_delta
		drag_position = event.position


func handle_connect_input(event: InputEvent):
	print("Is pressed: ", event.is_pressed(), " Is action pressed: ", event.is_action_pressed("click"))
	print("Type ", event)
	if event is InputEventMouseButton:
		if event.is_pressed():
			print("initiate connect")
			var mouse_position = get_viewport().get_mouse_position()
			var selection = object_at_position(mouse_position)
			if selection != null:
				create_connector(selection)
				is_dragging = true
				print("connect initiated at ", selection)
			else:
				print("Empty connect click")
				is_dragging = false
		elif event.is_released():
			is_dragging = false
			if current_connector != null:
				current_connector.free()
				
	elif event is InputEventMouseMotion and is_dragging:
		print("Connect to: ", event.position)
		drag_position = event.position
		update_connector(drag_position)


func create_connector(origin):
	var connector = Node2D.new()
	connector.name = "connector"
	add_child(connector)
	connector_origin = origin
	current_connector = connector
	update_connector(origin.position)
	
func update_connector(target_location):
	if connector_origin == null:
		return
	if current_connector == null:
		return
	
	var line = current_connector.get_node("connector_line")
	if not line:
		line = Line2D.new()
		line.name = "connector_line"
		current_connector.add_child(line)
		
	line.clear_points()
	
	line.add_point(connector_origin.position)
	line.add_point(target_location)
	

func add_node(position: Vector2):
	print("Adding node")
	var scene = load("res://diagram_node.tscn")
	var instance: DiagramNode = DiagramNode.new()
	instance.set_position(position)
	add_child(instance)
