extends Control

@export var laboratory_scene : PackedScene

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

func _exit_fade_out_tween() -> Tween:
	var tween = self.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_property(AudioManager.main_menu_theme, "volume_db", -80, 1.0)
	return tween

func _on_respawn_pressed() -> void:
	GameManager.load_game()
	var tween = _exit_fade_out_tween()
	await tween.finished
	AudioManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/level/TheLaboratory.tscn")
