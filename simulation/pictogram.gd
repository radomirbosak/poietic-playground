class_name Pictogram extends Object

const tile_size = 50
const default_image_scale = 1.7

var name: String
var shape: Shape2D
var svg_buffer: PackedByteArray

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

func get_texture(scale: float = default_image_scale) -> ImageTexture:
	return ImageTexture.create_from_image(get_image(scale))
