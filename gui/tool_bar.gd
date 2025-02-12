class_name ToolBar extends PanelContainer

@onready var selection_tool_button: IconButton = %SelectionToolButton
@onready var place_tool_button: IconButton = %PlaceToolButton
@onready var connection_tool_button: IconButton = %ConnectToolButton

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
