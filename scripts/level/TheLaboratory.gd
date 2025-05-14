extends Node2D

var player_in_power_area = false

@onready var wave_manager = $MapLayerCopy/WaveManager
@onready var player_node = $Player
@onready var player_sprite = $Player/AnimatedSprite

@onready var initial_beep = $LabAudioManager/InitialBeep
@onready var beep1 = $LabAudioManager/Beep1
@onready var beep2 = $LabAudioManager/Beep2
@onready var beep3 = $LabAudioManager/Beep3

func _load_saved():
	var game_data = Globals.game_data
	
	player_node.health = game_data.player_health
	player_node.position.x = game_data.player_x
	player_node.position.y = game_data.player_y
	player_node.speed = game_data.player_speed
	player_node.wave_cooldown = game_data.player_wave_cooldown

# Called when the node enters the scene tree for the first time.
func _start_game():
	player_sprite.play("sleep1")
	var tween = create_tween()
	tween.tween_interval(initial_beep.stream.get_length()-2.73)
	initial_beep.play()
	await tween.finished
	player_node.visible = true
	beep1.play()
	await beep1.finished
	beep2.play()
	await beep2.finished
	beep3.play()
	await beep3.finished
	tween = create_tween()
	tween.tween_interval(2)
	await tween.finished
	player_sprite.play("idle1")
	tween = create_tween()
	tween.tween_interval(2)
	await tween.finished
	GameManager.start_dialogue("timeline")
	get_viewport().set_input_as_handled()
	
func _ready() -> void:
	$CanvasLayer/PauseMenu.save_game.connect(self.save_game)
	
	if not GameManager.game_started:
		Globals.game_data = null
		_start_game()
		GameManager.game_started = true
		GameManager.save_game(self)
	else:
		if (Globals.game_data != null):
			_load_saved()

		GameManager.movement_disabled = false
		player_node.visible = true
	
	wave_manager.player_node = player_node
	player_node.trigger_wave.connect(wave_manager.emit_wave)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_power_area:
		player_node.stage += 1
		


func _on_dialogue_trigger_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.start_dialogue("guide")
	$DialogueTrigger1.queue_free()
	
func save_game():
	GameManager.save_game(self)


func _on_next_stage_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not player_in_power_area:
		player_in_power_area = true
		
		
func _on_next_stage_trigger_body_exited(body: Node2D) -> void:
	if body.name == "Player" and player_in_power_area:
		player_in_power_area = false
