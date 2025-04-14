class_name ToolBar extends PanelContainer

@onready var selection_tool_button: Button = %SelectionToolButton
@onready var place_tool_button: Button = %PlaceToolButton
@onready var connection_tool_button: Button = %ConnectToolButton

func _ready():
	_initialize_connector_types()

	Global.tool_changed.connect(_on_tool_changed)
	Global.change_tool(Global.selection_tool)
	
func _initialize_connector_types():
	var connector_types: Array[String] = ["Flow", "Parameter", "Comment"]
	for type in connector_types:
		pass

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

func _on_selection_tool_button_pressed():
	Global.change_tool(Global.selection_tool)

func _on_place_tool_button_pressed():
	Global.change_tool(Global.place_tool)

func _on_connect_tool_button_pressed():
	Global.change_tool(Global.connect_tool)
