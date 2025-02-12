extends Node

signal drag_session_started(position: Vector2, item: Variant)
signal drag_session_entered(position: Vector2)
signal drag_session_updated(position: Vector2)
signal drag_session_exited(position: Vector2)
signal drag_session_ended(position: Vector2)
signal drag_session_cancelled()

var selection_tool = SelectionTool.new()
var place_tool = PlaceTool.new()
var connect_tool = ConnectTool.new()

var modal_node: Node = null
var current_tool: CanvasTool = selection_tool
var canvas: DiagramCanvas = null

signal tool_changed(tool: CanvasTool)

func _ready():
	# Initialize globals here
	Pictogram.load_pictograms()
	pass

func change_tool(tool: CanvasTool) -> void:
	print("CHANGE TOOL FROM: ", current_tool.tool_name(), " TO ", tool.tool_name())
	current_tool = tool
	tool_changed.emit(tool)
