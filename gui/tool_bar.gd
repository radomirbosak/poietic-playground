class_name ToolBar extends PanelContainer

@onready var selection_tool_button: Button = $HBoxContainer/SelectionToolButton
@onready var connection_tool_button: Button = $HBoxContainer/ConnectToolButton

func _ready():
	Global.tool_changed.connect(_on_tool_changed)
	print("HERE: ", selection_tool_button)

func _on_tool_changed(tool: CanvasTool):
	if tool is SelectionTool:
		selection_tool_button.button_pressed = true
		connection_tool_button.button_pressed = false
	elif tool is SelectionTool:
		selection_tool_button.button_pressed = false
		connection_tool_button.button_pressed = true
	else:
		push_error("Unknown tool: ", tool)

func _on_selection_tool_button_pressed():
	Global.change_tool(Global.selection_tool)

func _on_connect_tool_button_pressed():
	Global.change_tool(Global.connect_tool)
