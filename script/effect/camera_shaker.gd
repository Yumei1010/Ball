# camera_shaker.gd (V3.0 - 最终丝滑版)
extends Camera2D

@export var decay_rate: float = 5.0 # 衰减速率，值越大，抖动停止得越快

var shake_strength: float = 0.0 # 当前的抖动强度
var shake_rng = RandomNumberGenerator.new() # 一个随机数生成器

# 传入一个数值，代表这次冲击的“力度”
func apply_shake(strength: float) -> void:
	# 将新的冲击力度，与现有的抖动强度叠加，让抖动可以“累积”
	shake_strength += strength

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, delta * decay_rate)
		
		var random_direction = Vector2.from_angle(shake_rng.randf_range(0, TAU))
		
		offset = random_direction * shake_strength
	else:
		# 确保完全停止后，归位
		shake_strength = 0.0
		offset = Vector2.ZERO
