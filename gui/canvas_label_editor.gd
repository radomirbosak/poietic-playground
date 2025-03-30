class_name CanvasLabelEditor extends LineEdit

signal editing_submitted(new_text: String)
signal editing_cancelled

var _original_text: String
var _original_center: Vector2
var _min_width: float = 0.0

func open(text: String, global_rect: Rect2):
	_original_text = text
	self.text = text
	
	_original_center = global_rect.get_center()
	_min_width = global_rect.size.x
	
	global_position = global_rect.position
	size.x = _min_width
	
	show()
	grab_focus()
	select_all()
	set_process(true)

func _ready():
	hide()
	set_process(false)
	focus_exited.connect(_on_focus_exited)
	text_changed.connect(_on_text_changed)
	text_submitted.connect(_on_text_submitted)

func _process(_delta):
	# Dynamic sizing while maintaining center position
	var text_width = get_minimum_size().x
	var new_width = max(text_width, _min_width)
	
	# Keep centered on original label's center
	var new_position = Vector2(
		_original_center.x - new_width / 2,
		global_position.y
	)
	
	# Only update if changed to avoid infinite loops
	if size.x != new_width or global_position.x != new_position.x:
		size.x = new_width
		global_position.x = new_position.x

func _on_text_changed(new_text: String):
	# Trigger resize on text change
	pass  # _process handles it automatically

func _on_text_submitted(new_text: String):
	set_process(false)
	hide()
	editing_submitted.emit(new_text)

func _on_focus_exited():
	if visible:  # Only if still editing
		set_process(false)
		hide()
		editing_cancelled.emit()

func _input(event):
	if visible and event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			set_process(false)
			hide()
			editing_cancelled.emit()
			get_viewport().set_input_as_handled()
