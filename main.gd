extends Node2D

const SETTINGS_FILE = "user://settings.cfg"
const default_window_size = Vector2(1280, 720)

@onready var canvas: DiagramCanvas = %Canvas
@onready var inspector_panel: InspectorPanel = %InspectorPanel
@onready var help_panel: Panel = $Gui/HelpPanel

func _init():
	pass

func _ready():
	load_settings()
	get_viewport().connect("size_changed", _on_window_resized)
	
	Global.initialize()

	Global.canvas = canvas
	Global.design.design_changed.connect(canvas._on_design_changed)
	GlobalSimulator.simulation_step.connect(canvas._on_simulation_step)
	canvas.selection.selection_changed.connect(inspector_panel._on_selection_changed)
	canvas.sync_design()

	Global.design.design_changed.connect(_on_design_changed)
	update_status_text()

func _on_design_changed():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("selection-tool"):
		Global.change_tool(Global.selection_tool)
	elif event.is_action_pressed("place-tool"):
		Global.change_tool(Global.place_tool)
	elif event.is_action_pressed("connect-tool"):
		Global.change_tool(Global.connect_tool)
	elif event.is_action_pressed("help-toggle"):
		toggle_help()
	elif event.is_action_pressed("inspector-toggle"):
		toggle_inspector()

	elif event.is_action_pressed("redo"):
		if Global.design.can_redo():
			Global.design.redo()
		else:
			printerr("Trying to redo while having nothing to redo")

	elif event.is_action_pressed("undo"):
		if Global.design.can_undo():
			Global.design.undo()
		else:
			printerr("Trying to undo while having nothing to undo")
			

	elif event.is_action_pressed("run"):
		toggle_run()
	elif event.is_action_pressed("delete"):
		delete_selection()

func _process(_delta):
	update_status_text()

func update_status_text():
	var text = ""
	text += "Nodes: " + str(len(Global.design.get_diagram_nodes())) + " Edges: " + str(len(Global.design.get_diagram_edges()))
	$Gui/StatusText.text = text

func _on_window_resized():
	save_settings()

func toggle_help():
	if help_panel.visible:
		help_panel.hide()
	else:
		help_panel.show()
	save_settings()

func toggle_inspector():
	if inspector_panel.visible:
		inspector_panel.hide()
	else:
		inspector_panel.show()
	save_settings()

func toggle_run():
	if GlobalSimulator.is_running:
		GlobalSimulator.stop()
	else:
		GlobalSimulator.run()
	
func delete_selection():
	canvas.delete_selection()

func load_settings():
	var config = ConfigFile.new()
	var load_result = config.load(SETTINGS_FILE)
	if load_result != OK:
		push_warning("Settings file not loaded")
		return

	var window_size = Vector2(
		config.get_value("window", "width", default_window_size.x),
		config.get_value("window", "height", default_window_size.y)
		)
	if config.get_value("help", "visible", true):
		help_panel.show()
	else:
		help_panel.hide()

	if config.get_value("inspector", "visible", true):
		inspector_panel.show()
	else:
		inspector_panel.hide()
	DisplayServer.window_set_size(window_size)

func save_settings():
	var window_size = DisplayServer.window_get_size()
	var config = ConfigFile.new()
	if config.load(SETTINGS_FILE) != OK:
		# Just warn, do not return, but proceed with new settings.
		push_warning("Unable to load settings")
	
	config.set_value("window", "width", window_size.x)
	config.set_value("window", "height", window_size.y)
	config.set_value("help", "visible", help_panel.visible)
	config.set_value("inspector", "visible", inspector_panel.visible)
	config.save(SETTINGS_FILE)
