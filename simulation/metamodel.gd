extends Node

const placeable_nodes = ["Stock", "Flow", "Auxiliary", "GraphicalFunction", "Smooth", "Delay"]

var thing: int = 10

static var _all_pictograms: Dictionary = {}
static var default_pictogram: Pictogram

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_pictograms()
	
func _load_pictograms():
	# TODO: Adjust the scales based on the rules for the pictogram sizes (not yet defined)
	var circle = CircleShape2D.new()
	circle.radius = Pictogram.tile_size / Pictogram.default_image_scale
	var square = RectangleShape2D.new()
	square.size = Vector2(Pictogram.tile_size, Pictogram.tile_size)
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(Pictogram.tile_size * 3, Pictogram.tile_size * 2)
	var flow_shape = CircleShape2D.new()
	flow_shape.radius = Pictogram.tile_size * 0.8
	
	_all_pictograms.clear()
	
	default_pictogram = Pictogram.new("Unknown", square)
	_all_pictograms["default"] = default_pictogram
	var pictograms: Array[Pictogram]= [
		Pictogram.new("Stock", rectangle),
		Pictogram.new("Flow", flow_shape),
		Pictogram.new("Auxiliary", circle),
		Pictogram.new("GraphicalFunction", circle),
		Pictogram.new("Smooth", square),
		Pictogram.new("Delay", square)
	]
	for pictogram in pictograms:
		_all_pictograms[pictogram.name] = pictogram

func get_placeable_pictograms() -> Array[Pictogram]:
	var result: Array[Pictogram]
	for name in placeable_nodes:
		result.append(get_pictogram(name))
	return result

static func get_pictogram(name: String) -> Pictogram:
	var pictogram = _all_pictograms[name]
	if pictogram:
		return pictogram
	else:
		push_warning("Unknown pictogram: ", name)
		return default_pictogram
