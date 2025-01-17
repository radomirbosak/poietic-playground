extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().connect("size_changed", Callable(self, "_on_window_resized"))
	create_demo()
	update_status_text()

	var config = ConfigFile.new()
	var load_result = config.load("user://settings.cfg")
	if load_result == OK:
		var window_size = Vector2(
			config.get_value("window", "width", 1280),
			config.get_value("window", "height", 720)
			)
		if config.get_value("help", "visible", true):
			$Gui/HelpPanel.show()
		else:
			$Gui/HelpPanel.hide()
		DisplayServer.window_set_size(window_size)

	%InspectorPanel.canvas = $DiagramCanvas

func create_demo():
	var a = $DiagramCanvas.create_node(Vector2(200, 200), "one")
	var b = $DiagramCanvas.create_node(Vector2(400, 250), "two")
	var c = $DiagramCanvas.create_node(Vector2(300, 400), "three")
	$DiagramCanvas.add_connection(a, b)
	$DiagramCanvas.add_connection(b, c)

func _unhandled_input(event):
	if event.is_action_pressed("selection-tool"):
		Global.current_tool = Global.selection_tool
	elif event.is_action_pressed("connect-tool"):
		Global.current_tool = Global.connect_tool
	elif event.is_action_pressed("help-toggle"):
		toggle_help()
	elif event.is_action_pressed("inspector-toggle"):
		toggle_inspector()
	elif event.is_action_pressed("add-node"):
		var mouse_position = get_viewport().get_mouse_position()
		var new_postion = $DiagramCanvas.to_local(mouse_position)
		$DiagramCanvas.create_node(new_postion, "node")

	elif event.is_action_pressed("delete"):
		$DiagramCanvas.delete_selection()

func _process(delta):
	update_status_text()

func update_status_text():
	var text = "Tool: "
	var tool = Global.current_tool
	if tool != null:
		text += tool.tool_name()
	else:
		text += "(none)"
		
	text += " | Child count: " + str($DiagramCanvas.get_child_count())
	$Gui/StatusText.text = text

func _on_window_resized():
	var window_size = DisplayServer.window_get_size()
	var config = ConfigFile.new()
	var load_result = config.load("user://settings.cfg")
	config.set_value("window", "width", window_size.x)
	config.set_value("window", "height", window_size.y)
	config.save("user://settings.cfg")

func toggle_help():
	if $Gui/HelpPanel.visible:
		print("Hide")
		$Gui/HelpPanel.hide()
	else:
		print("Show")
		$Gui/HelpPanel.show()

	var config = ConfigFile.new()
	var load_result = config.load("user://settings.cfg")
	config.set_value("help", "visible", $Gui/HelpPanel.visible)
	config.save("user://settings.cfg")

func toggle_inspector():
	if $Gui/InspectorPanel.visible:
		$Gui/InspectorPanel.hide()
	else:
		$Gui/InspectorPanel.show()
