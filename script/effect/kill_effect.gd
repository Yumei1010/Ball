extends AnimatedSprite2D

# Degraded mode — sprite frames deleted.
# Plays SFX + scale-pulse then self-destructs.


func _ready() -> void:
	var audio := get_node_or_null("AudioStreamPlayer2D") as AudioStreamPlayer2D
	if audio:
		var rng := RandomNumberGenerator.new()
		var time_scaled: float = lerp(1.0, float(Engine.time_scale), 0.6)
		audio.pitch_scale = time_scaled * rng.randf_range(0.75, 1.0)
		audio.play()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.finished.connect(queue_free)
