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
	palette.set_callout_point(callout_position)
	palette.place_object.connect(_on_place_object)

func close_panel():
	# canvas.remove_child(palette)
	if palette:
		Global.close_modal(palette)
		palette.place_object.disconnect(_on_place_object)

func _on_place_object(position: Vector2, name: String):
	push_error("Place object not implemented")
	#var local_position = canvas.to_local(position)
	#var object = DesignObject.new(name, "unnamed", local_position)
	#object.set_name(name.to_lower() + "_" + str(object.object_id))
	#Design.global.add_object(object)
	#close_panel()

func input_began(_event: InputEvent, pointer_position: Vector2):
	open_panel(pointer_position)
	Global.set_modal(palette)
	
func input_ended(_event: InputEvent, pointer_position: Vector2):
	pass
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	pass

func release():
	close_panel()
