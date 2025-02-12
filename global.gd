extends Node

var selection_tool = SelectionTool.new()
var place_tool = PlaceTool.new()
var connect_tool = ConnectTool.new()

var modal_node: Node = null
var current_tool: CanvasTool = selection_tool
var canvas: DiagramCanvas = null

signal tool_changed(tool: CanvasTool)

func _ready():
	# Initialize globals here
	# Pictogram.load_pictograms()
	pass

func change_tool(tool: CanvasTool) -> void:
	current_tool = tool
	tool_changed.emit(tool)
