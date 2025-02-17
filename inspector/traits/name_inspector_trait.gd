extends InspectorTraitPanel

@onready var label: Label = $VBoxContainer/Label
@onready var name_field: LineEdit = $VBoxContainer/NameField

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_selection_changed():
	var distinct_label = selection.get_distinct_values("name")

	if len(distinct_label) == 0:
		name_field.text = ""
	elif len(distinct_label) == 1:
		name_field.text = str(distinct_label[0])
	else:
		name_field.text = "(multiple)"

func _on_name_field_text_submitted(new_name):
	for object in selection.objects:
		var design_object = Design.global.get_object(object.object_id)
		design_object.set_name(new_name)
	# FIXME: This needs to be called from a change transaction
	Design.global.design_changed.emit()
