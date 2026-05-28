extends Sprite2D

# Bounce counter visual — uses PlaceholderArt runtime textures.
# No more frame PNGs (3210/ deleted, PlaceholderArt generates them).

var _tween: Tween
var _is_disappearing: bool = false


func animate_spawn(bounce_count: int) -> void:
	if _is_disappearing: return
	var idx: int = clampi(bounce_count - 1, 0, 3)
	texture = PlaceholderArt.textures.get("bounce_%d" % idx)

	if is_instance_valid(_tween): _tween.kill()
	scale = Vector2.ONE * 0.6
	modulate.a = 0.0
	show()

	var scale_tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.3)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.5)

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15)


func animate_reset() -> void:
	if is_instance_valid(_tween): _tween.kill()
	_is_disappearing = true
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.set_parallel()
	_tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.finished.connect(queue_free)


func animate_break() -> void:
	if is_instance_valid(_tween): _tween.kill()
	_is_disappearing = true
	texture = PlaceholderArt.textures.get("bounce_0")
	show()
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.set_parallel()
	_tween.tween_property(self, "scale", Vector2.ONE * 2.0, 0.25)
	_tween.tween_property(self, "modulate:a", 0.0, 0.25)
	_tween.finished.connect(queue_free)
