class_name PlaceTool extends CanvasTool

var last_pointer_position = Vector2()

var palette_scene: PackedScene = preload("res://gui/object_palette.tscn")
var palette: ObjectPalette

func tool_name() -> String:
	return "place"

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
	if !Global.design.metamodel.has_type(type_name):
		push_error("Unknown design object type: ", type_name)
		return
	var trans = Global.design.new_transaction()
	var count = len(Global.design.get_diagram_nodes())
	var name = type_name.to_snake_case() + str(count)
	var local_position = canvas.to_local(position)
	print("Create object of type: ", type_name, " name: ", name, " at: ", position, )
	var node = trans.create_node(type_name, name, {"position": local_position})
	print("Object created: ", node)
	Global.design.accept(trans)
	canvas.selection.replace(PackedInt64Array([node]))
	close_panel()


func input_began(_event: InputEvent, pointer_position: Vector2):
	open_panel(pointer_position)
	Global.set_modal(palette)
	
func input_ended(_event: InputEvent, pointer_position: Vector2):
	pass
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	pass

func tool_released():
	close_panel()
