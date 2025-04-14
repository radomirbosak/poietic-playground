class_name PlaceTool extends CanvasTool

var last_pointer_position = Vector2()

var palette_scene: PackedScene = preload("res://gui/object_palette.tscn")
var palette: ObjectPalette

func tool_name() -> String:
	return "place"

func tool_selected():
	object_panel.show()
	object_panel.load_node_pictograms()

	if last_selected_object_identifier:
		object_panel.selected_item = last_selected_object_identifier
	else:
		object_panel.selected_item = "Stock"

func tool_released():
	last_selected_object_identifier = object_panel.selected_item
	close_panel()

# TODO: Remove or re-purpose
func open_panel(callout_position: Vector2):
	if palette == null:
		palette = palette_scene.instantiate()
	palette.visible = true
	# canvas.add_child(palette)
	Global.set_modal(palette)
	palette.point_side = palette.recommended_point_side(callout_position)
	palette.set_position_with_target(callout_position)
	palette.place_object.connect(_on_place_object)

func close_panel():
	# canvas.remove_child(palette)
	if palette:
		Global.close_modal(palette)
		palette.place_object.disconnect(_on_place_object)

func _on_place_object(position: Vector2, type_name: String):
	place_object(position, type_name)
	close_panel()

func place_object(position: Vector2, type_name: String):
	var trans = design.new_transaction()
	var count = len(design.get_diagram_nodes())
	var name = type_name.to_snake_case() + str(count)
	var local_position = canvas.to_local(position)
	var node = trans.create_node(type_name, name, {"position": local_position})
	print("Created object of type: ", type_name, " name: ", name, " at: ", position, )
	design.accept(trans)
	canvas.selection.replace(PackedInt64Array([node]))


func input_began(_event: InputEvent, pointer_position: Vector2):
	# TODO: Add shadow (also on input moved)
	# open_panel(pointer_position)
	# Global.set_modal(palette)
	pass
	
func input_ended(_event: InputEvent, pointer_position: Vector2):
	place_object(pointer_position, object_panel.selected_item)
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	pass
