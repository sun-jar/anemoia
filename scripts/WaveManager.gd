extends Node2D

signal door_matched

var player_node: CharacterBody2D
var wave_node: Variant

@export var wave: PackedScene

var door_id = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func emit_wave():
	wave_node = wave.instantiate()
	wave_node.global_position = player_node.global_position
	wave_node.sound_id = door_id
	add_child(wave_node)
	wave_node.emit_wave()
	
