class_name PlaceTool extends CanvasTool

var last_pointer_position = Vector2()

var palette_scene: PackedScene = preload("res://gui/object_palette.tscn")
var palette: ObjectPalette

func tool_name() -> String:
	return "place"

func wants_hover_events() -> bool:
	return true

func tool_selected():
	object_panel.show()
	object_panel.load_node_pictograms()
	object_panel.selection_changed.connect(_on_object_selection_changed)

	if last_selected_object_identifier:
		object_panel.selected_item = last_selected_object_identifier
	else:
		object_panel.selected_item = "Stock"

func tool_released():
	last_selected_object_identifier = object_panel.selected_item
	object_panel.selection_changed.disconnect(_on_object_selection_changed)
	remove_intent_shadow()
	close_panel()

func _on_object_selection_changed(identifier: String):
	if intent_shadow:
		remove_intent_shadow()
	create_intent_shadow(identifier, Vector2.ZERO)


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
	# create_intent_shadow(object_panel.selected_item, pointer_position)
	pass
	
func input_ended(_event: InputEvent, pointer_position: Vector2):
	place_object(pointer_position, object_panel.selected_item)
	# remove_intent_shadow()
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	if intent_shadow:
		intent_shadow.position += canvas.to_local(move_delta)
		return true

func input_hover(event: InputEvent, pointer_position: Vector2) -> bool:
	if intent_shadow:
		intent_shadow.position = canvas.to_local(pointer_position)
	return true

var intent_shadow: Node2D = null

func create_intent_shadow(type_name: String, pointer_position: Vector2):
	print("Creating shadow of type ", type_name)
	assert(canvas != null)
	assert(intent_shadow == null)
	
	intent_shadow = Sprite2D.new()
	var pictogram: Pictogram = Global.get_pictogram(type_name)
	intent_shadow.texture = ImageTexture.create_from_image(pictogram.get_image())
	intent_shadow.modulate = Color(0.5, 0.5, 0.1, 0.8) 
	canvas.add_child(intent_shadow)
	intent_shadow.position = canvas.to_local(pointer_position)

func remove_intent_shadow():
	if not intent_shadow:
		return
	intent_shadow.free()
