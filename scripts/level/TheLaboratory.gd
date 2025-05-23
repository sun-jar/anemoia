extends Node2D

@onready var wave_manager = $MapLayerCopy/WaveManager
@onready var player_node = $Player
@onready var player_sprite = $Player/AnimationPlayer

@onready var mask_layers = $MapLayerCopy/MaskLayers
@onready var map_layer = $MapLayer
@onready var map_stage_1 = $MapLayer/Stage1MapLayer
@onready var map_stage_2 = $MapLayer/Stage2MapLayer
@onready var map_stage_3 = $MapLayer/Stage3MapLayer

@onready var initial_beep = $LabAudioManager/InitialBeep
@onready var beep1 = $LabAudioManager/Beep1
@onready var beep2 = $LabAudioManager/Beep2
@onready var beep3 = $LabAudioManager/Beep3

@onready var interact_timer = $InteractTimer

@export var map_stage_1_scene: PackedScene
@export var map_stage_2_scene: PackedScene

@export var respawn_screen: PackedScene

var power_source_scene = preload("res://scenes/interactables/PowerSource.tscn")
var map_stage_1_scene_ins
var map_stage_2_scene_ins

var player_in_power_area = false
var is_new_game = false

func _load_saved():
	var game_data = Globals.game_data
	
	if GameManager.player_stage > 1:
		_init_stage_2()
	
	if GameManager.player_stage > 2:
		_init_stage_3()
	
	player_node.health = game_data.player_health
	player_node.position.x = game_data.player_x
	player_node.position.y = game_data.player_y
	player_node.speed = game_data.player_speed
	player_node.wave_cooldown = game_data.player_wave_cooldown

# Called when the node enters the scene tree for the first time.
func _start_game():
	GameManager.reset_player_state(player_node)
	player_sprite.play("sleep1")
	var tween = create_tween()
	tween.tween_interval(initial_beep.stream.get_length()-2.73)
	mask_layers.modulate.a = 1.0
	initial_beep.play()
	await tween.finished
	
	player_node.modulate.a = 1.0
	map_layer.visible = true
	
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
	AudioManager.play_room_tone()
	GameManager.die.connect(_respawn)
	$CanvasLayer/PauseMenu.save_game.connect(self._save_game)
	if not GameManager.game_started:
		is_new_game = true
		Globals.game_data = null
		_start_game()
		GameManager.game_started = true
		GameManager.save_game(self)
	else:
		is_new_game = false
		if (Globals.game_data != null):
			_load_saved()

		player_node.anim.play("idle" + str(GameManager.player_stage))
		
		create_tween().tween_property(player_node, "modulate:a", 1.0, 2.0)
		var mask_tween = create_tween()
		mask_tween.tween_property(mask_layers, "modulate:a", 1.0, 2.0)
		await mask_tween.finished
		map_layer.visible = true
		
		GameManager.movement_disabled = false
	
	if is_new_game:
		GameManager.dialogue_finished.connect($Player/InitialGuide.show_initial_guide)
		player_node.trigger_wave.connect($Player/InitialGuide.advance_guide)
	else:
		$Player/InitialGuide.queue_free()
	wave_manager.player_node = player_node
	wave_manager.door_matched.connect(open_door)
	
	player_node.trigger_wave.connect(wave_manager.emit_wave)
	player_node.trigger_wave.connect(calculate_pitch)
	for i in range(1,3):
		var powers = get_node_or_null("%" + ("Power%d" % i))
		if powers != null:
			powers.play("active_%d" % i)
	
	
func calculate_pitch():
	var next_wave_trigger = get_node("%" + ("Power%d" % GameManager.player_stage))
	var triger_position = Vector2(next_wave_trigger.position.x, next_wave_trigger.position.y)
	var player_position = Vector2(player_node.position.x / 2, player_node.position.y / 2) # to balance out, because the map layers are scaled by 2
	var trigger_distance = triger_position.distance_to(player_position)
	
	var scaled_distance = -(trigger_distance / 200) - 15 # fine tuned constants
	
	AudioServer.set_bus_volume_db(1, -scaled_distance - 30)
	
	var pitch_scale = AudioServer.get_bus_effect(1, 1)
	pitch_scale.pitch_scale = max(((scaled_distance + 36) / 21) * 0.8, 0.2)

	
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
	if with_effect:
		var power_node_path = "MapLayer/Stage%dMapLayer/Power%d" % [GameManager.player_stage - 1, GameManager.player_stage - 1]
		var power_node = get_node_or_null(power_node_path)
		power_node.play("inactive_" + str(GameManager.player_stage - 1))
		
		player_node.anim.play("idle" + str(GameManager.player_stage))
		GameManager.movement_disabled = true
		
		var next_level_wave = wave_manager.wave.instantiate()
		next_level_wave.global_position = player_node.global_position
		wave_manager.add_child(next_level_wave)
		$Player/Camera2D.shake(8.0, 2.0)
		
		var fade_tween = next_level_wave.emit_shockwave()
		
		if GameManager.player_stage == 3:
			map_stage_1_scene_ins.queue_free()
		
		await fade_tween.finished
		power_node.queue_free()
		next_level_wave.safe_queue_free()
	
	if GameManager.player_stage == 2:
		_init_stage_2()
	
	elif GameManager.player_stage == 3:
		_init_stage_3()
	
	if with_effect:
		GameManager.movement_disabled = false

func _init_stage_2():
	map_stage_1.queue_free()
	map_stage_1_scene_ins = map_stage_1_scene.instantiate()
	var power_source_display = power_source_scene.instantiate()
	power_source_display.play("inactive_1")
	power_source_display.position = Vector2(1397.65, -1722)
	map_stage_1_scene_ins.add_child(power_source_display)
	map_stage_1_scene_ins.modulate = Color(1.0/3.0, 1.0/3.0, 1.0/3.0)
	map_stage_1_scene_ins.collision_enabled = false
	mask_layers.add_child(map_stage_1_scene_ins)
	
	for child in map_stage_1_scene_ins.get_children():
		if child.name in map_stage_2.switches:
			child.toggle_enable("1")
			
	for child in map_stage_2.get_children():
		if child.name in map_stage_2.switches:
			child.toggle_enable("2")

	await get_tree().process_frame

	GameManager.closed_doors[0] = true
	_draw_door0(map_stage_1_scene_ins, GameManager.door0)
	
	map_stage_2.visible = true
	map_stage_2.collision_enabled = true
	
func _init_stage_3():
	map_stage_2.queue_free()
	map_stage_2_scene_ins = map_stage_2_scene.instantiate()
	map_stage_2_scene_ins.modulate = Color(1.0/3.0, 1.0/3.0, 1.0/3.0)
	map_stage_2_scene_ins.collision_enabled = false
	mask_layers.add_child(map_stage_2_scene_ins)
	
	for child in map_stage_2_scene_ins.get_children():
		if child.name in map_stage_3.switches:
			child.disabled = false
			# TODO GANTI SPRITE SWITCH DI MAP LAYER 2 INSTANCE DISINI
			
	map_stage_3.open_doors()
	
	await get_tree().process_frame
	map_stage_3.visible = true
	map_stage_3.collision_enabled = true

func _on_dialogue_trigger_1_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not GameManager.shown_one_time_dialogues["guide"]:
		GameManager.start_dialogue("guide")
	$DialogueTrigger1.queue_free()
	
func _save_game():
	GameManager.save_game(self)


func _on_next_stage_trigger_1_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not player_in_power_area and GameManager.player_stage == 1:
		player_in_power_area = true
		
		
func _on_next_stage_trigger_1_body_exited(body: Node2D) -> void:
	if body.name == "Player" and player_in_power_area:
		player_in_power_area = false
		if Input.is_action_pressed("interact"):
			AudioManager.stop_shockwave()
			interact_timer.stop()
			$Player/Camera2D.stop_buildup_shake()


func _on_next_stage_trigger_2_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not player_in_power_area and GameManager.player_stage == 2:
		player_in_power_area = true


func _on_next_stage_trigger_2_body_exited(body: Node2D) -> void:
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


func _respawn():
	player_node.anim.play("death" + str(GameManager.player_stage))
	# temporarily use a timer to make sure the animation plays
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(respawn_screen)

# special case for door 0
func _draw_door0(layer, coords):
	for coord in coords:
		layer.set_cell(coord, 2, Vector2i(4, 2))

func open_door(id):
	GameManager.closed_doors[id] = true
	if GameManager.player_stage == 2:
		if id in [1, 2, 6, 8, 10]:
			map_stage_1_scene_ins._delete_4x3_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_2._delete_4x3_door(GameManager.doors[id], 2, Vector2i(5, 2))
		if id in [3, 5, 11]:
			map_stage_1_scene_ins._delete_4x1_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_2._delete_4x1_door(GameManager.doors[id], 2, Vector2i(5, 2))
		if id == 11:
			map_stage_1_scene_ins._delete_5x1_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_2._delete_5x1_door(GameManager.doors[id], 2, Vector2i(5, 2))
		if id == 4:
			map_stage_1_scene_ins._delete_6x3_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_2._delete_6x3_door(GameManager.doors[id], 2, Vector2i(5, 2))
	if GameManager.player_stage == 3  :
		if id in [1, 2, 6, 8, 10]:
			map_stage_2_scene_ins._delete_4x3_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_3._delete_4x3_door(GameManager.doors[id], 2, Vector2i(5, 2))
		if id in [3, 5, 11]:
			map_stage_2_scene_ins._delete_4x1_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_3._delete_4x1_door(GameManager.doors[id], 2, Vector2i(5, 2))
		if id == 11:
			map_stage_2_scene_ins._delete_5x1_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_3._delete_5x1_door(GameManager.doors[id], 2, Vector2i(5, 2))
		if id == 4:
			map_stage_2_scene_ins._delete_6x3_door(GameManager.doors[id], 2, Vector2i(4, 3))
			map_stage_3._delete_6x3_door(GameManager.doors[id], 2, Vector2i(5, 2))


func _on_dialogue_power_source_1_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not GameManager.shown_one_time_dialogues["intro_power_source_1"]:
		GameManager.start_dialogue("intro_power_source_1")   


func _on_dialogue_power_source_1_trigger_body_exited(body: Node2D) -> void:
	if body.name == "Player" and not GameManager.shown_one_time_dialogues["intro_power_source_2"]:
		GameManager.start_dialogue("intro_power_source_2")
		$DialoguePowerSource1Trigger.queue_free()
