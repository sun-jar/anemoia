extends Control

func _ready() -> void:
	visible = false

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
	unpause()
	get_tree().change_scene_to_file("res://scenes/user_interface/MainMenu.tscn")

func _on_unpause_pressed() -> void:
	unpause()
