extends Node2D

var player_node: CharacterBody2D

@export var wave: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func emit_wave():
	var wave_node = wave.instantiate()
	wave_node.global_position = player_node.global_position
	add_child(wave_node)
	
	var wave_tween = create_tween()
	var fade_tween = create_tween()
	wave_tween.tween_property(wave_node, "scale", Vector2(0.7, 0.7), 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(wave_node, "modulate:a", 0.0, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	wave_tween.tween_callback(Callable(wave_node, "queue_free"))
	
