extends Node

var selection_tool = SelectionTool.new()
var connect_tool = ConnectTool.new()

var current_tool: CanvasTool = selection_tool

func _ready():
	# Initialize globals here
	pass
