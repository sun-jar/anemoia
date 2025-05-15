extends Sprite2D

var chroma_shader = preload("res://scripts/shaders/WaveChroma.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_shader_tween(material: ShaderMaterial, parameter_name: String, from_value, to_value, duration: float) -> Tween:
	var tween = create_tween()
	var set_shader_param = func(value):
		material.set_shader_parameter(parameter_name, value)
	tween.tween_method(set_shader_param, from_value, to_value, duration)
	return tween
	
func emit_wave():
	var wave_tween = create_tween()
	var fade_tween = create_tween()
	wave_tween.tween_property(self, "scale", Vector2(0.7, 0.7), 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(self, "modulate:a", 0.0, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await wave_tween.finished
	
	queue_free()
	
func emit_shockwave():
	var chroma_material = ShaderMaterial.new()
	chroma_material.shader = chroma_shader
	self.material = chroma_material

	var radius_tween = create_shader_tween(chroma_material, "radius", 0.1, 1.0, 2.0)
	var fade_tween = create_shader_tween(chroma_material, "alpha", 1.0, 1.0 / 3.0, 4.0)
	var r_displacement_tween = create_shader_tween(chroma_material, "r_displacement", Vector2(4.0, 2.0), Vector2(0.0, 0.0), 4.0)
	var b_displacement_tween = create_shader_tween(chroma_material, "b_displacement", Vector2(-4.0, -1.0), Vector2(0.0, 0.0), 4.0)

	var expand_tween = create_tween()
	expand_tween.tween_property(self, "scale", Vector2(3.0, 3.0), 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	return fade_tween
	
func safe_queue_free():
	visible = false
	await get_tree().process_frame
	queue_free()
