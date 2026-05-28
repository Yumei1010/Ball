# breakthrough_effect.gd
extends Label

func animate(score_text: String) -> void:
	text = score_text
	
	var tween = create_tween()
	tween.set_parallel() # 让放大和渐隐同时发生
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT) # 使用平滑的曲线

	#    在 0.8 秒内，将 scale 从 1.0 放大到 1.5 倍
	tween.tween_property(self, "scale", Vector2.ONE * 1.5, 0.8)
	
	#    在同样的 0.8 秒内，将 modulate:a (透明度) 从 1.0 变为 0.0
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	
	await tween.finished
	queue_free()
