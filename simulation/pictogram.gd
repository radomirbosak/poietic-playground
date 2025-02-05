class_name Pictogram extends Object

const tile_size = 50
const default_image_scale = 1.7

var name: String
var shape: Shape2D
var svg_buffer: PackedByteArray

static var _internal_pictograms: Array[Pictogram] = []
static var default: Pictogram

static func load_pictograms():
	# TODO: Adjust the scales based on the rules for the pictogram sizes (not yet defined)
	var circle = CircleShape2D.new()
	circle.radius = tile_size / default_image_scale
	var square = RectangleShape2D.new()
	square.size = Vector2(tile_size, tile_size)
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(tile_size * 3, tile_size * 2)
	var flow_shape = CircleShape2D.new()
	flow_shape.radius = tile_size * 0.8
	
	_internal_pictograms.clear()
	Pictogram.default = Pictogram.new("Unknown", square)
	_internal_pictograms.append(Pictogram.default)
	_internal_pictograms.append(Pictogram.new("Stock", rectangle))
	_internal_pictograms.append(Pictogram.new("Flow", flow_shape))
	_internal_pictograms.append(Pictogram.new("Auxiliary", circle))
	_internal_pictograms.append(Pictogram.new("GraphicalFunction", circle))
	_internal_pictograms.append(Pictogram.new("Smooth", square))
	_internal_pictograms.append(Pictogram.new("Delay", square))

static func get_pictogram(name: String) -> Pictogram:
	if _internal_pictograms.is_empty():
		load_pictograms()
		
	for picto in _internal_pictograms:
		if picto.name == name:
			return picto
	return Pictogram.default

func _init(name: String, shape: Shape2D):
	self.name = name
	self.shape = shape
	var path = "res://resources/pictograms/" + name + ".svg"
	self.svg_buffer = FileAccess.get_file_as_bytes(path)

func get_image(scale: float = default_image_scale) -> Image:
	var image = Image.new()
	if image.load_svg_from_buffer(svg_buffer, scale) == OK:
		for x in range(0, image.get_width()):
			for y in range(0, image.get_height()):
				var pixel = image.get_pixel(x, y)
				image.set_pixel(x, y, pixel.inverted())
	return image	
