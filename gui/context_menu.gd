extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_name_button_pressed():
	pass # Replace with function body.


func _on_formula_button_pressed():
	pass # Replace with function body.


func _on_auto_button_pressed():
	pass # Replace with function body.


func _on_delete_button_pressed():
	Global.canvas.delete_selection()
	Global.close_modal(Global.modal_node)
