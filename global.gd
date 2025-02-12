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

func get_gui() -> Node:
	return get_node("/root/Main/Gui")
	
func set_modal(node: Node):
	if modal_node:
		push_warning("Setting modal while having one already set")
		get_gui().remove_child(modal_node)

	modal_node = node
	get_gui().add_child(modal_node)

func close_modal(node: Node):
	if node != modal_node:
		# Sanity check
		push_error("Trying to close a different modal")
	if modal_node:
		get_gui().remove_child(modal_node)
		modal_node = null

func change_tool(tool: CanvasTool) -> void:
	if current_tool:
		current_tool.release()
	current_tool = tool
	tool_changed.emit(tool)
