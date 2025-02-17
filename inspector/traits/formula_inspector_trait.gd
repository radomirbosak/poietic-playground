extends InspectorTraitPanel

var _is_updating: bool = false

@onready var label: Label = $VBoxContainer/Label
@onready var formula_field: TextEdit = $VBoxContainer/FormulaField

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_selection_changed():
	var distinct_values = selection.get_distinct_values("formula")

	if len(distinct_values) == 0:
		formula_field.text = ""
	elif len(distinct_values) == 1:
		formula_field.text = str(distinct_values[0])
	else:
		formula_field.text = "(multiple)"

func _on_formula_field_text_set():
	if not _is_updating:
		update_formula()
	
func update_formula():
	var text = formula_field.text
	for object in selection.objects:
		var design_object = Design.global.get_object(object.object_id)
		design_object.set_attribute("formula", text)
	# FIXME: This needs to be called from a change transaction
	Design.global.design_changed.emit()

func _on_formula_field_gui_input(event):
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_ESCAPE
				or (event.keycode == KEY_ENTER and not event.shift_pressed)):
			_is_updating = true
			update_formula()
			formula_field.release_focus()
			_is_updating = false
