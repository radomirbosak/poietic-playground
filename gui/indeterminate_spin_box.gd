class_name IndeterminateSpinBox extends SpinBox

signal value_committed(value: float)

var is_indeterminate := false:
	set(value):
		is_indeterminate = value
		var line_edit = get_line_edit()
		queue_redraw()
		if value:
			line_edit.text = "--"
			line_edit.editable = false
		else:
			line_edit.editable = true

func _ready():
	var line_edit = get_line_edit()
	line_edit.focus_entered.connect(_on_focus_entered)
	line_edit.focus_exited.connect(_on_focus_exited)

func _on_focus_entered():
	if is_indeterminate:
		is_indeterminate = false
		value = 1.0  # Default value when interacting
		get_line_edit().select_all()

func _on_focus_exited():
	value_committed.emit(value)
