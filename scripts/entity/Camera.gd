extends Camera2D

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var shake_fade: float = 0.0
var is_shaking = false

var is_buildup_shake = false
var buildup_time: float = 0.0
var buildup_duration: float = 0.0
var buildup_max_strength: float = 0.0
var buildup_min_strength: float = 0.0
var is_done = false

func _process(delta: float) -> void:
	if is_shaking:
		if shake_strength > 0.1:
			print(shake_strength)
			shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
			offset = _random_offset()
		else:
			is_shaking = false
			shake_fade = 0.0
			shake_strength = 0.0
			offset = Vector2.ZERO
	elif is_buildup_shake:
		buildup_time = min(buildup_time + delta, buildup_duration)
		var t = buildup_time / buildup_duration
		shake_strength = lerp(buildup_min_strength, buildup_max_strength, t)
		offset = _random_offset()
		if buildup_time >= buildup_duration:
			is_buildup_shake = false
	else:
		offset = Vector2.ZERO

func shake(random_strength, fade_intensity):
	shake_strength = random_strength
	shake_fade = fade_intensity
	is_shaking = true
	is_buildup_shake = false

func start_buildup_shake(duration, min_strength, max_strength):
	print("called buildup shake")
	buildup_duration = duration
	buildup_min_strength = min_strength
	buildup_max_strength = max_strength
	is_buildup_shake = true

func stop_buildup_shake():
	print("stopped buildup shake")
	buildup_duration = 0.0
	buildup_min_strength = 0.0
	buildup_max_strength = 0.0
	buildup_time = 0.0
	if is_buildup_shake:
		shake(shake_strength, 4.0)
	is_buildup_shake = false

func _random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
