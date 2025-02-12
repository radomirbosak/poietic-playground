class_name PlaceTool extends CanvasTool

var last_pointer_position = Vector2()

var palette_scene: PackedScene = preload("res://gui/object_palette.tscn")
var palette: ObjectPalette

func tool_name() -> String:
	return "place"

func open_panel(callout_position: Vector2):
	if palette == null:
		palette = palette_scene.instantiate()
	palette.set_callout_position(callout_position)
	palette.visible = true
	# canvas.add_child(palette)
	Global.set_modal(palette)
	palette.place_object.connect(_on_place_object)

func close_panel():
	# canvas.remove_child(palette)
	if palette:
		Global.close_modal(palette)
		palette.place_object.disconnect(_on_place_object)

func _on_place_object(position: Vector2, name: String):
	print("PLACE ", name, " AT ", position)
	var local_position = canvas.to_local(position)
	var object = DesignObject.new(name, "unnamed", local_position)
	object.set_name(name.to_lower() + "_" + str(object.object_id))
	Design.global.add_object(object)
	close_panel()

func input_began(_event: InputEvent, pointer_position: Vector2):
	print("POS: ", pointer_position)
	open_panel(pointer_position)
	Global.set_modal(palette)
	
func input_ended(_event: InputEvent, pointer_position: Vector2):
	print("Place Tool: END")
	
func input_moved(_event: InputEvent, move_delta: Vector2):
	print("Place Tool: MOVE")

func release():
	close_panel()
