## Prompt manager manages context specific user inputs that are associated phyisically and visually
## with objects in the canvas.
##
## Prompt manager opens and closes prompts, makes sure only one prompt is open and hands-off
## prompt results in form of signals.
##
class_name CanvasPromptManager extends Node

@onready var formula_prompt: FormulaPrompt = $FormulaPrompt
@onready var label_editor: CanvasLabelEditor = $LabelEditor
@onready var context_menu: ContextMenu = $ContextMenu

var current_prompt: Control = null
var canvas: DiagramCanvas = null

func initialize(canvas: DiagramCanvas):
	self.canvas = canvas
	formula_prompt.initialize(canvas, self)
	label_editor.initialize(canvas, self)
	context_menu.initialize(canvas, self)

	label_editor.editing_submitted.connect(canvas._on_label_edit_submitted)
	label_editor.editing_cancelled.connect(canvas._on_label_edit_cancelled)
	formula_prompt.formula_editing_submitted.connect(canvas._on_formula_edit_submitted)
	formula_prompt.formula_editing_cancelled.connect(canvas._on_formula_edit_cancelled)

func open_label_editor(object_id: int, text: String, center: Vector2):
	close()
	current_prompt = label_editor
	label_editor.open(object_id, text, center)

func open_name_editor_for(object_id: int):
	var node = canvas.get_diagram_node(object_id)
	if not node:
		push_warning("Unknown node for name editor. ID: ", object_id)
		return
	var center = Vector2(node.global_position.x, node.name_label.global_position.y)
	open_label_editor(node.object_id, node.object_name, center)

func open_formula_editor(object_id: int, text: String, center: Vector2):
	close()
	current_prompt = formula_prompt
	formula_prompt.open(object_id, text, center)

func open_formula_editor_for(object_id: int):
	var position = canvas.get_formula_prompt_position(object_id)
	var object: PoieticObject = Global.design.get_object(object_id)
	var formula = object.get_attribute("formula")
	open_formula_editor(object_id, formula, position)

func open_context_menu(selection: PoieticSelection, desired_position: Vector2):
	# var menu: PanelContainer = preload("res://gui/context_menu.tscn").instantiate()
	close()
	current_prompt = context_menu
	context_menu.open(selection, desired_position)

func close():
	if current_prompt:
		current_prompt.close()
	current_prompt = null
