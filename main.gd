extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().connect("size_changed", Callable(self, "_on_window_resized"))
	var a = $DiagramCanvas.add_node(Vector2(200, 200))
	var b = $DiagramCanvas.add_node(Vector2(400, 250))
	$DiagramCanvas.add_connection(a, b)
	update_status_text()

	var config = ConfigFile.new()
	var load_result = config.load("user://settings.cfg")
	if load_result == OK:
		var window_size = Vector2(
			config.get_value("window", "width", 1280),
			config.get_value("window", "height", 720)
			)
		DisplayServer.window_set_size(window_size)


func _input(event):
	if event.is_action_pressed("connect-tool"):
		set_tool(Global.Tool.CONNECT)
	elif event.is_action_pressed("selection-tool"):
		set_tool(Global.Tool.SELECT)

	elif event.is_action_pressed("add-node"):
		var mouse_position = get_viewport().get_mouse_position()
		var new_postion = $DiagramCanvas.to_local(mouse_position)
		$DiagramCanvas.add_node(new_postion)

	elif event.is_action_pressed("delete"):
		print("Delete (not yet)")

		

func set_tool(tool: Global.Tool):
	print("Use tool: ", tool)
	Global.current_tool = tool
	update_status_text()

func _process(delta):
	update_status_text()

func update_status_text():
	var text = "Tool: "
	if Global.current_tool == Global.Tool.SELECT:
		text += "select"
	elif Global.current_tool == Global.Tool.CONNECT:
		text += "connect"
	else:
		text += "(UNKNOWN TOOL)"
		
	text += " | Child count: " + str($DiagramCanvas.get_child_count())
	$StatusText.text = text
		

func _on_window_resized():
	var window_size = DisplayServer.window_get_size()
	var config = ConfigFile.new()
	config.set_value("window", "width", window_size.x)
	config.set_value("window", "height", window_size.y)
	config.save("user://settings.cfg")
