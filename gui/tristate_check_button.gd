class_name TriStateCheckButton extends CheckButton

enum State { UNCHECKED, CHECKED, INDETERMINATE }
@export var state: State = State.UNCHECKED

var on_texture = preload("res://resources/icons/check-button-on.png")
var off_texture = preload("res://resources/icons/check-button-off.png")
var indeterminate_texture = preload("res://resources/icons/check-button-indeterminate.png")

func _ready():
	# button_pressed = false
	toggle_mode = true
	add_theme_icon_override("checked", on_texture)
	add_theme_icon_override("unchecked", off_texture)
	set_state_no_signal(state)

func set_state_no_signal(new_state: State):
	state = new_state
	match state:
		State.CHECKED:
			set_pressed_no_signal(true)
		State.UNCHECKED:
			set_pressed_no_signal(false)
			add_theme_icon_override("unchecked", off_texture)
		State.INDETERMINATE:
			set_pressed_no_signal(false)
			add_theme_icon_override("unchecked", indeterminate_texture)

	queue_redraw()

func _pressed():
	print("PRESSED")

func _toggled(button_pressed: bool):
	print("TOGGLED")
	# Convert indeterminate state to checked when clicked
	if button_pressed:
		set_state_no_signal(State.CHECKED)
	else:
		set_state_no_signal(State.UNCHECKED)
