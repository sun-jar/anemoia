extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_main_menu_pressed() -> void:
	AudioManager.stop_room_tone()
	GameManager.movement_disabled = true
	get_tree().change_scene_to_file("res://scenes/user_interface/MainMenu.tscn")
