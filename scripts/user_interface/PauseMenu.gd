extends Control

signal save_game

@onready var save_complete_label = $MarginContainer/VBoxContainer2/SaveCompleteLabel
@onready var confirmation_screen = $ConfirmationScreen
var just_saved = false

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
	just_saved = false
	save_complete_label.text = ""
	
func _on_main_menu_pressed() -> void:
	if just_saved:
		exit()
	else:
		confirmation_screen.visible = true

func _on_unpause_pressed() -> void:
	unpause()

func _on_save_pressed() -> void:
	emit_signal("save_game")
	save_complete_label.text = "Save complete."
	just_saved = true

func _on_cancel_pressed() -> void:
	confirmation_screen.visible = false

func _on_proceed_main_menu_pressed() -> void:
	exit()
	
func exit():
	AudioManager.stop_room_tone()
	GameManager.movement_disabled = true
	unpause()
	get_tree().change_scene_to_file("res://scenes/user_interface/MainMenu.tscn")
