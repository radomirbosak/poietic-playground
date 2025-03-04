class_name ToolBar extends PanelContainer

@onready var undo_button: TextureButton = %UndoButton
@onready var redo_button: TextureButton = %RedoButton

@onready var selection_tool_button: IconButton = %SelectionToolButton
@onready var place_tool_button: IconButton = %PlaceToolButton
@onready var connection_tool_button: IconButton = %ConnectToolButton

var items: Array[Item] = []

class Item:
	var tag: int
	var label: String
	var icon: Icon
	
	func _init(tag: int, label: String, icon: Icon):
		self.tag = tag
		self.label = label
		self.icon = icon

func _ready():
	Global.tool_changed.connect(_on_tool_changed)
	Global.change_tool(Global.selection_tool)

func _on_tool_changed(tool: CanvasTool):
	if tool is SelectionTool:
		selection_tool_button.set_pressed_no_signal(true)
		place_tool_button.set_pressed_no_signal(false)
		connection_tool_button.set_pressed_no_signal(false)
	elif tool is PlaceTool:
		selection_tool_button.set_pressed_no_signal(false)
		place_tool_button.set_pressed_no_signal(true)
		connection_tool_button.set_pressed_no_signal(false)
	elif tool is ConnectTool:
		selection_tool_button.set_pressed_no_signal(false)
		place_tool_button.set_pressed_no_signal(false)
		connection_tool_button.set_pressed_no_signal(true)
	else:
		push_error("Unknown tool: ", tool)
	selection_tool_button.update_shader()
	place_tool_button.update_shader()
	connection_tool_button.update_shader()

func _on_selection_tool_button_pressed():
	Global.change_tool(Global.selection_tool)

func _on_place_tool_button_pressed():
	Global.change_tool(Global.place_tool)

func _on_connect_tool_button_pressed():
	Global.change_tool(Global.connect_tool)


func _on_undo_button_pressed():
	if Global.design.can_undo():
		Global.design.undo()
	else:
		printerr("Trying to undo while having nothing to undo")

func _on_redo_button_pressed():
	if Global.design.can_redo():
		Global.design.redo()
	else:
		printerr("Trying to redo while having nothing to redo")
