extends Label


func _ready():
	get_tree().root.connect("size_changed", Callable(self, "_on_window_resized"))
	# get_viewport().connect("size_changed", self, "_on_window_resized")
	adjust_position()

func adjust_position():
	print("Adjust")
	var window_size: Vector2 = get_viewport().size 
	var label_size: Vector2 = get_size()

	position = window_size - label_size - Vector2(10, 10)

func _on_window_resized():
	adjust_position()
