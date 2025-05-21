extends Control

signal save_game

@onready var save_complete_label = $MarginContainer/VBoxContainer2/SaveCompleteLabel

func _ready() -> void:
	visible = false
	save_complete_label.text = ""

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		visible = !visible

func unpause():
	get_tree().paused = false
	visible = false
	
func _on_main_menu_pressed() -> void:
	AudioManager.stop_room_tone()
	GameManager.movement_disabled = true
	unpause()
	get_tree().change_scene_to_file("res://scenes/user_interface/MainMenu.tscn")

func _on_unpause_pressed() -> void:
	unpause()
	save_complete_label.text = ""

func _on_save_pressed() -> void:
	emit_signal("save_game")
	save_complete_label.text = "Save complete."
