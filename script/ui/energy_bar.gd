extends TextureProgressBar

const BAR_W := 200
const BAR_H := 24

var _fill_color: Color

func _ready() -> void:
	match name:
		"EnergyBar":
			_fill_color = Color(0.2, 0.6, 1.0)
		"EnergyBar2":
			_fill_color = Color(1.0, 0.85, 0.1)
		_:
			_fill_color = Color(0.9, 0.2, 0.2)

	texture_under = _make_rect(Color(0.15, 0.15, 0.15, 0.6))
	texture_over = _make_rect(Color(0.15, 0.15, 0.15, 0.6))
	texture_progress = _make_rect(_fill_color)

func update_progress(new_value: float) -> void:
	value = new_value

func _make_rect(color: Color) -> ImageTexture:
	var img: Image = Image.create(BAR_W, BAR_H, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
