extends Node

# View Preferences

var show_value_indicators: bool = false

# Canvas Tools
var selection_tool = SelectionTool.new()
var place_tool = PlaceTool.new()
var connect_tool = ConnectTool.new()

# Poietic: Data
var metamodel: PoieticMetamodel
var result: PoieticResult

# Poietic: Controllers/Managers/Functioning components
var design: PoieticDesignController
var player: PoieticPlayer

# Application State
var modal_node: Node = null
var current_tool: CanvasTool = selection_tool
var canvas: DiagramCanvas = null

signal tool_changed(tool: CanvasTool)

func initialize():
	print("Initializing globals ...")

	InspectorTraitPanel._initialize_panels()
	Pictogram._load_pictograms()

	print("Initializing design ...")

	metamodel = PoieticMetamodel.new()
	design = PoieticDesignController.new()
	player = PoieticPlayer.new()
	_create_demo_design()
	
	print("Done initializing.")
	
func _create_demo_design():
	var trans = design.new_transaction()
	var a = trans.create_node("Stock", "source", {"position": Vector2(400, 300), "formula": 5})
	var b = trans.create_node("FlowRate", "flow", {"position": Vector2(600, 300), "formula": "x * 0.01"})
	var c = trans.create_node("Stock", "target", {"position": Vector2(800, 300), "formula": 0})
	var d = trans.create_node("Auxiliary", "x", {"position": Vector2(400, 500), "formula": 10})
	var ab = trans.create_edge("Flow", a, b)
	var bc = trans.create_edge("Flow", b, c)
	var db = trans.create_edge("Parameter", d, b)
	design.accept(trans)


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
		current_tool.tool_released()
	current_tool = tool
	current_tool.tool_selected()
	tool_changed.emit(tool)

func open_object_context_menu(object: Variant, position: Vector2):
	var menu = CallOut.new()
	var box = HBoxContainer.new()
	menu.add_child(box)
	var b1 = Button.new()
	b1.text = "one"
	box.add_child(b1)
	menu.set_callout_point(position)
	# canvas.add_child(palette)
	Global.set_modal(menu)
