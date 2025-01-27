extends Node2D

@onready var canvas: DiagramCanvas = %DiagramCanvas
var design: Design

func _init():
	design = Design.global

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().connect("size_changed", _on_window_resized)
	create_demo_design()
	update_status_text()
	print("Objects: ", len(design.all_objects()), " nodes: ", len(design.all_nodes()), " edges: ", len(design.all_edges()))
	canvas.sync_design()

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

func create_demo_design():
	var a = DesignObject.new("Stock", "source", Vector2(200, 200), randi() % 100)
	var b = DesignObject.new("Flow", "flow", Vector2(400, 200), randi() % 100)
	var c = DesignObject.new("Stock", "sink", Vector2(600, 200), randi() % 100)
	var ab = DesignObject.new("Drains")
	ab.origin = a.object_id
	ab.target = b.object_id
	
	var bc = DesignObject.new("Fills")
	bc.origin = b.object_id
	bc.target = c.object_id
	
	design.add_object(a)
	design.add_object(b)
	design.add_object(c)
	design.add_object(ab)
	design.add_object(bc)

func _unhandled_input(event):
	if event.is_action_pressed("selection-tool"):
		Global.change_tool(Global.selection_tool)
	elif event.is_action_pressed("connect-tool"):
		Global.change_tool(Global.connect_tool)
	elif event.is_action_pressed("help-toggle"):
		toggle_help()
	elif event.is_action_pressed("inspector-toggle"):
		toggle_inspector()
	elif event.is_action_pressed("run"):
		toggle_run()
	elif event.is_action_pressed("add-node"):
		add_node()
	elif event.is_action_pressed("delete"):
		delete_selection()

func _process(_delta):
	update_status_text()

func update_status_text():
	var text = "Tool: "
	var tool = Global.current_tool
	if tool != null:
		text += tool.tool_name()
	else:
		text += "(none)"
		
	text += " | Nodes: " + str(len(design.all_nodes())) + " Edges: " + str(len(design.all_edges()))
	$Gui/StatusText.text = text

func _on_window_resized():
	var window_size = DisplayServer.window_get_size()
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
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
	config.load("user://settings.cfg")
	config.set_value("help", "visible", $Gui/HelpPanel.visible)
	config.save("user://settings.cfg")

func toggle_inspector():
	if $Gui/InspectorPanel.visible:
		$Gui/InspectorPanel.hide()
	else:
		$Gui/InspectorPanel.show()

func toggle_run():
	if GlobalSimulator.is_running:
		GlobalSimulator.stop()
	else:
		GlobalSimulator.run()

func add_node():
	var mouse_position = get_viewport().get_mouse_position()
	var new_postion = canvas.to_local(mouse_position)

	var object: DesignObject = DesignObject.new("Auxiliary", "node", new_postion, randi() % 100)
	object.set_name("node" + str(object.object_id))
	design.add_object(object)
	canvas.queue_sync()
	
func delete_selection():
	canvas.delete_selection()
