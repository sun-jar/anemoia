extends Node2D

var nameless_sleep = preload("res://assets/entity/nameless_sleep_1.png")
var nameless_awake = preload("res://assets/entity/nameless_1.png")

@onready var wave_manager = $MapLayerCopy/WaveManager
@onready var player_node = $Player

@onready var initial_beep = $LabAudioManager/InitialBeep
@onready var beep1 = $LabAudioManager/Beep1
@onready var beep2 = $LabAudioManager/Beep2
@onready var beep3 = $LabAudioManager/Beep3

# Called when the node enters the scene tree for the first time.
func _start_game():
	$Player/EntitySprite.texture = nameless_sleep
	var tween = create_tween()
	tween.tween_interval(initial_beep.stream.get_length()-2.73)
	initial_beep.play()
	await tween.finished
	$Player.visible = true
	beep1.play()
	await beep1.finished
	beep2.play()
	await beep2.finished
	beep3.play()
	await beep3.finished
	tween = create_tween()
	tween.tween_interval(2)
	await tween.finished
	$Player/EntitySprite.texture = nameless_awake
	Dialogic.start("timeline")
	get_viewport().set_input_as_handled()
	
func _ready() -> void:
	if not GameManager.game_started:
		await _start_game()
	# TODO: ini movement ga disabled kalo dialog masih jalan
	# so harus ada cara buat disable dlu UNTIL dialogue finishes
	GameManager.movement_disabled = false
	player_node.visible = true
	
	wave_manager.player_node = player_node
	player_node.trigger_wave.connect(wave_manager.emit_wave)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
