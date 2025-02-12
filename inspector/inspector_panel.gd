class_name InspectorPanel extends PanelContainer

## Panel for inspecting diagram elements.
##

var selection: Selection

func get_type_id(type_name: String):
	match type_name:
		"stock": return 1
		"flow": return 2
		"auxiliary": return 3
		_: return 0
		

func _ready():
	update_known_types()

func _on_diagram_canvas_selection_changed(new_selection):
	self.selection = new_selection
	
	print("Selection changed: ", selection.count(), " nodes selected")
	
	var distinct_label = selection.get_distinct_values("label")

	if len(distinct_label) == 0:
		%NameField.text = ""
	elif len(distinct_label) == 1:
		%NameField.text = str(distinct_label[0])
	else:
		%NameField.text = "(multiple)"
		
	var distinct_type = selection.get_distinct_values("type_name")
	
	if len(distinct_type) == 0:
		%TypeButton.select(%TypeButton.get_item_index(0))
	elif len(distinct_type) == 1:
		var type_name = distinct_type[0]
		var id = get_type_id(type_name)
		%TypeButton.select(%TypeButton.get_item_index(id))
	else:
		%TypeButton.select(%TypeButton.get_item_index(0))
	
	pass # Replace with function body.

func update_known_types():
	%TypeButton.clear()
	%TypeButton.add_item("Unknown", 0)
	%TypeButton.add_item("Stock", 1)
	%TypeButton.add_item("Flow", 2)
	%TypeButton.add_item("Auxiliary", 3)
	%TypeButton.select(0)

func _on_name_field_text_submitted(new_name):
	for object in selection.objects:
		var design_object = Design.global.get_object(object.object_id)
		design_object.set_name(new_name)
	# FIXME: This needs to be called from a change transaction
	Design.global.design_changed.emit()
