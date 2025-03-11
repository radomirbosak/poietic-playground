extends Node2D

const DEFAULT_SAVE_PATH = "user://design.poietic"
const SETTINGS_FILE = "user://settings.cfg"
const default_window_size = Vector2(1280, 720)

@onready var canvas: DiagramCanvas = %Canvas
@onready var inspector_panel: InspectorPanel = %InspectorPanel

func _init():
	pass

func _ready():
	load_settings()
	get_viewport().connect("size_changed", _on_window_resized)
	
	Global.initialize()

	# Initialize and connect canvas
	Global.canvas = canvas
	Global.design.design_changed.connect(canvas._on_design_changed)
	GlobalSimulator.simulation_step.connect(canvas._on_simulation_step)

	# Connect inspector
	Global.design.design_changed.connect(inspector_panel._on_design_changed)
	canvas.selection.selection_changed.connect(inspector_panel._on_selection_changed)
	# TODO: See inspector panel source comment about selection
	inspector_panel.selection = canvas.selection
	
	# Finalize initalisation
	canvas.sync_design()
	Global.design.design_changed.connect(_on_design_changed)
	update_status_text()

func _on_design_changed():
	update_status_text()

func _unhandled_input(event):
	# TODO: Document inputs
	if event.is_action_pressed("selection-tool"):
		Global.change_tool(Global.selection_tool)
	elif event.is_action_pressed("place-tool"):
		Global.change_tool(Global.place_tool)
	elif event.is_action_pressed("connect-tool"):
		Global.change_tool(Global.connect_tool)

	# File
	elif event.is_action_pressed("save-design"):
		save_design()
	elif event.is_action_pressed("open-design"):
		open_design()
	elif event.is_action_pressed("import"):
		import_foreign_frame()


	# Edit
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
			
	elif event.is_action_pressed("auto-connec-parameters"):
		auto_connect_parameters()

	elif event.is_action_pressed("inspector-toggle"):
		toggle_inspector()
	elif event.is_action_pressed("run"):
		toggle_run()
	elif event.is_action_pressed("delete"):
		delete_selection()

func update_status_text():
	var stats = Global.design.debugStats
	
	var text = ""
	text += "Frames: " + str(stats["frames"])
	text += " undo: " + str(stats["undo_frames"])
	text += " redo: " + str(stats["redo_frames"])
	text += "\n"
	text += "Frame: " + str(stats["current_frame"])
	if stats["diagram_nodes"] == stats["nodes"]:
		text += " nodes: " + str(stats["nodes"])
	else:
		text += " nodes: " + str(stats["diagram_nodes"]) + "/" + str(stats["nodes"])
	text += " edges: " + str(stats["edges"])
	text += " | design issues: " + str(stats["design_issues"])
	text += " object issues: " + str(stats["object_issues"])
	$Gui/StatusText.text = text

func _on_window_resized():
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
	config.set_value("inspector", "visible", inspector_panel.visible)
	config.save(SETTINGS_FILE)

func open_design():
	var path = ProjectSettings.globalize_path(DEFAULT_SAVE_PATH)
	print("Loading design from: ", path)
	Global.design.load_from_path(path)

func save_design():
	var path = ProjectSettings.globalize_path(DEFAULT_SAVE_PATH)
	print("Saving design to: ", path)
	Global.design.save_to_path(path)

func auto_connect_parameters():
	Global.design.auto_connect_parameters()

func import_foreign_frame():
	var path = "/Users/stefan/Developer/Projects/poietic-examples/ThinkingInSystems/Capital.poieticframe"
	_on_file_dialog_dir_selected(path)
	return
	
	$FileDialog.use_native_dialog = false
	$FileDialog.current_path = "/Users/stefan/Developer/Projects/poietic-examples/ThinkingInSystems/"
	$FileDialog.access = FileDialog.Access.ACCESS_FILESYSTEM
	$FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_ANY
	$FileDialog.title = "Import Poietic Frame"
	$FileDialog.ok_button_text = "Import"
	
	$FileDialog.filters = ["*.poieticframe"]
	$FileDialog.show()

func _on_file_dialog_files_selected(paths):
	print("Files selected: ", paths)

func _on_file_dialog_dir_selected(dir):
	print("Importing: ", dir)
	Global.design.import_from_path(dir)

func _on_file_dialog_file_selected(path):
	print("File selected: ", path) 
