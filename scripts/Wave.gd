extends Sprite2D

var chroma_shader = preload("res://scripts/shaders/WaveChroma.gdshader")
@onready var beep_player = $WaveBeep
@onready var door_player = $DoorBeep
@onready var wave_hitbox = $Area2D

@onready var door_sound = [null]

@export var sound_id = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	for i in range(1, 12):
		door_sound.append(load("res://assets/sfx/doorbeeps/sound%d.wav" % i)) # gabisa preload karena preload gabisa format string (executed at compile time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func create_shader_tween(shader_material: ShaderMaterial, parameter_name: String, from_value, to_value, duration: float) -> Tween:
	var tween = create_tween()
	var set_shader_param = func(value):
		shader_material.set_shader_parameter(parameter_name, value)
	tween.tween_method(set_shader_param, from_value, to_value, duration)
	return tween
	
func emit_wave():
	var wave_tween = create_tween()
	var fade_tween = create_tween() 
	var hitbox_tween = create_tween()
	if sound_id == -1:
		beep_player.play()
	else:
		door_player.stream = door_sound[sound_id]
		door_player.play()
	wave_tween.tween_property(self, "scale", Vector2(0.7, 0.7), 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hitbox_tween.tween_property(wave_hitbox, "scale", Vector2(0.7, 0.7), 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT) #heuristic for the visual
	fade_tween.tween_property(self, "modulate:a", 0.0, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await wave_tween.finished
	await beep_player.finished
	
	queue_free()
	
func emit_shockwave():
	var chroma_material = ShaderMaterial.new()
	chroma_material.shader = chroma_shader
	self.material = chroma_material

	create_shader_tween(chroma_material, "radius", 0.1, 1.0, 2.0)
	create_shader_tween(chroma_material, "r_displacement", Vector2(5.0, 2.0), Vector2(0.0, 0.0), 4.0)
	create_shader_tween(chroma_material, "b_displacement", Vector2(-6.0, -4.0), Vector2(0.0, 0.0), 4.0)
	var fade_tween = create_shader_tween(chroma_material, "brightness", 1.0, (1.0/3.0), 4.0)

	var expand_tween = create_tween()
	var shrink_area2d_tween = create_tween()
	expand_tween.tween_property(self, "scale", Vector2(3.0, 3.0), 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	shrink_area2d_tween.tween_property($Area2D, "scale", Vector2(0.0025, 0.0025), 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	return fade_tween
	
func safe_queue_free():
	visible = false
	await get_tree().process_frame
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	var self_parent = self.get_parent()
	if parent.name.begins_with("Switch") and not parent.disabled:
		if sound_id != parent.id:
			door_player.stream = door_sound[parent.id]
			door_player.play()
		self_parent.door_id = parent.id
	if parent.name.begins_with("Door"):
		if sound_id == parent.id:
			self_parent.door_matched.emit(sound_id)
			self_parent.door_id = -1
		elif not GameManager.closed_doors[parent.id]:
			parent.sound_player.stream = door_sound[parent.id]
			parent.sound_player.play()
