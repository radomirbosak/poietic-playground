extends Node2D

const DEFAULT_SAVE_PATH = "user://design.poietic"
const SETTINGS_FILE = "user://settings.cfg"
const default_window_size = Vector2(1280, 720)

@onready var canvas: DiagramCanvas = %Canvas
@onready var player: PoieticPlayer = $SimulationPlayer
@onready var inspector_panel: InspectorPanel = %InspectorPanel
@onready var control_bar: ControlBar = $Gui/ControlBar

func _init():
	pass

func _ready():
	load_settings()
	get_viewport().connect("size_changed", _on_window_resized)
	
	Global.initialize()
	
	# Initialize and connect canvas
	Global.canvas = canvas

	# Connect inspector
	Global.design.design_changed.connect(inspector_panel._on_design_changed)
	canvas.selection.selection_changed.connect(inspector_panel._on_selection_changed)
	# TODO: See inspector panel source comment about selection
	inspector_panel.selection = canvas.selection
	
	# Simulation Player and Control Bar
	Global.player = player
	control_bar.update_simulator_state()
	
	# Finalize initalisation
	Global.design.design_changed.connect(self._on_design_changed)
	canvas.selection.selection_changed.connect(self._on_selection_changed)
	Global.design.simulation_started.connect(self._on_simulation_started)

	Global.design.simulation_finished.connect(self._on_simulation_success)
	Global.design.simulation_finished.connect(control_bar._on_simulation_success)

	Global.design.simulation_failed.connect(self._on_simulation_failure)
	Global.design.simulation_failed.connect(control_bar._on_simulation_failure)

	# Load demo design
	var path = ""
	if OS.has_feature("editor"):
		path = ProjectSettings.globalize_path("res://resources/new_canvas_demo_design.json")
	else:
		path = OS.get_executable_path().get_base_dir().path_join("resources").path_join("new_canvas_demo_design.json")
	import_foreign_frame_from(path)
	
	# Tell everyone about demo design
	# Global.design.design_changed.emit()
	update_status_text()
	
	print("Done initializing main.")

func _on_selection_changed(selection):
	_DEBUG_update_chart()

func _on_design_changed(has_issues: bool):
	# FIXME: Fix selection so that object IDs match
	canvas.sync_design()
	update_status_text()
	if has_issues:
		clear_result()

func _on_simulation_started():
	# TODO: Show some indicator to give hope.
	pass

func _on_simulation_success(result):
	# TODO: Send signal: result changed
	set_result(result)

func _on_simulation_failure():
	# TODO: Handle this, display some error somewhere, big, red or something
	clear_result()

func set_result(result):
	Global.result = result
	player.result = result
	canvas.sync_indicators(result)
	_DEBUG_update_chart()

func clear_result():
	Global.player.stop()
	Global.result = null
	Global.player.result = null
	canvas.clear_indicators()
	
func _on_simulation_player_step():
	canvas.update_indicator_values()
	
func _DEBUG_update_chart():
	var chart: Chart = $Gui/MakeshiftChart/Chart
	var ids = canvas.selection.get_ids()
	chart.clear_series()
	if ids and not ids.is_empty():
		for id in ids:
			print("Charting ", id)
			var series = Chart.TimeSeries.new()
			var data = Global.design.result_time_series(id)
			if not data:
				printerr("No data for ID ", id)
				continue
			series.time_min = 0.0
			series.time_delta = 1.0
			series.data = data
			chart.append_series(series)

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
		redo()
	elif event.is_action_pressed("undo"):
		undo()
			
	elif event.is_action_pressed("auto-connec-parameters"):
		auto_connect_parameters()

	elif event.is_action_pressed("inspector-toggle"):
		toggle_inspector()
	elif event.is_action_pressed("run"):
		toggle_run()
	elif event.is_action_pressed("delete"):
		delete_selection()

func redo():
	if Global.design.can_redo():
		Global.design.redo()
	else:
		printerr("Trying to redo while having nothing to redo")

func undo():
	if Global.design.can_undo():
		Global.design.undo()
	else:
		printerr("Trying to undo while having nothing to undo")

func update_status_text():
	var stats = Global.design.debug_stats
	
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
		$MenuBar/ViewMenu.set_item_checked(0, false)
	else:
		$MenuBar/ViewMenu.set_item_checked(0, true)
		inspector_panel.show()
	save_settings()

func toggle_value_indicators():
	if Global.show_value_indicators:
		Global.show_value_indicators = false
		$MenuBar/ViewMenu.set_item_checked(2, false)
	else:
		Global.show_value_indicators = true
		$MenuBar/ViewMenu.set_item_checked(2, true)
	save_settings()

func toggle_run():
	if Global.player.is_running:
		Global.player.stop()
	else:
		Global.player.run()
	
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
		$MenuBar/ViewMenu.set_item_checked(0, true)
		inspector_panel.show()
	else:
		$MenuBar/ViewMenu.set_item_checked(0, false)
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

func new_design():
	Global.design.new_design()

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
	$FileDialog.use_native_dialog = true
	$FileDialog.access = FileDialog.Access.ACCESS_FILESYSTEM
	$FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_ANY
	$FileDialog.title = "Import Poietic Frame"
	$FileDialog.ok_button_text = "Import"
	
	$FileDialog.filters = ["*.poieticframe"]
	$FileDialog.show()

func import_foreign_frame_from(path: String):
	Global.design.import_from_path(path)

func _on_file_dialog_files_selected(paths):
	print("Files selected: ", paths)

func _on_file_dialog_dir_selected(dir):
	print("Importing: ", dir)
	Global.design.import_from_path(dir)

func _on_file_dialog_file_selected(path):
	print("File selected: ", path) 

# Menu

func _on_file_menu_id_pressed(id):
	match id:
		0: new_design()
		1: open_design()
		2: save_design()
		4: import_foreign_frame()
		_: printerr("Unknown File menu id: ", id)

func _on_edit_menu_id_pressed(id):
	match id:
		0: undo()
		1: redo()
		2: pass # separator
		3: delete_selection()
		_: printerr("Unknown Edit menu id: ", id)

func _on_diagram_menu_id_pressed(id):
	match id:
		0: auto_connect_parameters()
		_: printerr("Unknown Diagram menu id: ", id)

func _on_view_menu_id_pressed(id):
	match id:
		0: toggle_inspector()
		1: pass # separator
		2: toggle_value_indicators()
		_: printerr("Unknown View menu id: ", id)
