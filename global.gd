extends Node

var selection_tool = SelectionTool.new()
var connect_tool = ConnectTool.new()

var current_tool: CanvasTool = selection_tool

signal tool_changed(tool: CanvasTool)

func _ready():
	# Initialize globals here
	pass

func change_tool(tool: CanvasTool) -> void:
	current_tool = tool
	tool_changed.emit(tool)
