extends Node2D

var player_in_power_area = false

@onready var wave_manager = $MapLayerCopy/WaveManager
@onready var player_node = $Player
@onready var player_sprite = $Player/AnimationPlayer

@onready var mask_layers = $MapLayerCopy/MaskLayers
@onready var map_stage_1 = $MapLayer/Stage1MapLayer
@onready var map_stage_2 = $MapLayer/Stage2MapLayer

@onready var initial_beep = $LabAudioManager/InitialBeep
@onready var beep1 = $LabAudioManager/Beep1
@onready var beep2 = $LabAudioManager/Beep2
@onready var beep3 = $LabAudioManager/Beep3

@onready var interact_timer = $InteractTimer

@onready var next_wave_trigger = get_node("%Power1")

@export var map_stage_1_scene: PackedScene

func _load_saved():
	var game_data = Globals.game_data
	
	GameManager.player_stage = game_data.player_stage
	
	player_node.health = game_data.player_health
	player_node.position.x = game_data.player_x
	player_node.position.y = game_data.player_y
	player_node.speed = game_data.player_speed
	player_node.wave_cooldown = game_data.player_wave_cooldown

# Called when the node enters the scene tree for the first time.
func _start_game():
	GameManager.reset_game(player_node)
	
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
		next_stage(false)

		GameManager.movement_disabled = false
		player_node.visible = true
	
	wave_manager.player_node = player_node
	player_node.trigger_wave.connect(wave_manager.emit_wave)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var triger_position = Vector2(next_wave_trigger.position.x, next_wave_trigger.position.y)
	var player_position = Vector2(player_node.position.x / 2, player_node.position.y / 2) # to balance out, because the map layers are scaled by 2
	var trigger_distance = triger_position.distance_to(player_position)
	
	var scaled_distance = -(trigger_distance / 200) - 15 # fine tuned constants
	
	AudioServer.set_bus_volume_db(1, -scaled_distance - 30)
	
	var pitch_scale = AudioServer.get_bus_effect(1, 1)
	pitch_scale.pitch_scale = ((scaled_distance + 36) / 21) * 0.8
	
func _input(event: InputEvent) -> void:
	if player_in_power_area:
		if event.is_action_pressed("interact"):
			AudioManager.play_shockwave()
			if not interact_timer.is_stopped():
				return
			interact_timer.start()
			$Player/Camera2D.start_buildup_shake(3.4, 0.2, 4.0)
		elif event.is_action_released("interact") and not interact_timer.is_stopped():
			AudioManager.stop_shockwave()
			interact_timer.stop()
			$Player/Camera2D.stop_buildup_shake()

func next_stage(with_effect: bool):
	if GameManager.player_stage == 2:
		var power_node_str = "MapLayer/Stage%dMapLayer/Power%d"
		var power_node_stage = [(GameManager.player_stage - 1), (GameManager.player_stage - 1)]
		var power_node = get_node_or_null(power_node_str % power_node_stage)
		power_node.material = null
		
		if with_effect:
			var next_level_wave = wave_manager.wave.instantiate()
			next_level_wave.global_position = player_node.global_position
			wave_manager.add_child(next_level_wave)
			$Player/Camera2D.shake(25.0, 2.0)
			
			var power_tween = create_tween()
			var fade_tween = next_level_wave.emit_shockwave()
			
			power_tween.tween_property(power_node, "modulate:a", 0.0, 3.0)
			
			await fade_tween.finished
			
			power_node.queue_free()
			next_level_wave.safe_queue_free()
		
		map_stage_1.queue_free()
		var map_stage_1_scene_ins = map_stage_1_scene.instantiate()
		map_stage_1_scene_ins.modulate = Color(1.0/3.0, 1.0/3.0, 1.0/3.0)
		map_stage_1_scene_ins.collision_enabled = false
		mask_layers.add_child(map_stage_1_scene_ins)
		
		await get_tree().process_frame
		map_stage_2.visible = true
		map_stage_2.collision_enabled = true
	

func _on_dialogue_trigger_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.start_dialogue("guide")
	$DialogueTrigger1.queue_free()
	
func save_game():
	GameManager.save_game(self)


func _on_next_stage_trigger_1_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not player_in_power_area:
		player_in_power_area = true
		
		
func _on_next_stage_trigger_1_body_exited(body: Node2D) -> void:
	if body.name == "Player" and player_in_power_area:
		player_in_power_area = false
		if Input.is_action_pressed("interact"):
			AudioManager.stop_shockwave()
			interact_timer.stop()
			$Player/Camera2D.stop_buildup_shake()

func _on_interact_timer_timeout() -> void:
	if player_in_power_area and Input.is_action_pressed("interact"):
		GameManager.player_stage += 1
		next_stage(true)
