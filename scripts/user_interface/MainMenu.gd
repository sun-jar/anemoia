extends Control

@onready var hover_stylebox := theme.get_stylebox("hover", "Button") as StyleBoxFlat
@onready var continue_game = get_node("%Continue")
@export var laboratory_scene : PackedScene

var animation_finished = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	var tween = self.create_tween()
	tween.tween_interval(0.5)
	tween.tween_property($ColorRect, "modulate:a", 1.0, 1.0)
	hover_stylebox.bg_color.a = 0.0
	await tween.finished
	AudioManager.play_music()
	animation_finished = true
	
	if (FileAccess.file_exists("res://savegame.json")):
		continue_game.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and animation_finished:
		var wave = preload("res://scenes/user_interface/MainMenuWave.tscn").instantiate()
		wave.global_position = get_global_mouse_position()
		add_child(wave)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_new_game_pressed() -> void:
	var tween = self.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($ColorRect, "modulate:a", 0.0, 1.0)
	tween.tween_property(AudioManager.main_menu_theme, "volume_db", -80, 1.0)
	await tween.finished
	GameManager.game_started = false
	get_tree().change_scene_to_packed(laboratory_scene)


func _on_continue_pressed() -> void:
	GameManager.game_started = true
	GameManager.load_game()
	get_tree().change_scene_to_packed(laboratory_scene)
