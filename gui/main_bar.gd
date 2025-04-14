extends PanelContainer

@onready var undo_button: Button = %UndoButton
@onready var redo_button: Button = %RedoButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_undo_button_pressed():
	if Global.design.can_undo():
		Global.design.undo()
	else:
		printerr("Trying to undo while having nothing to undo")

func _on_redo_button_pressed():
	if Global.design.can_redo():
		Global.design.redo()
	else:
		printerr("Trying to redo while having nothing to redo")
