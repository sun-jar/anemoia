extends Node2D

@onready var main_menu_theme = $MainMenuTheme

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func play_music():
	main_menu_theme.play()
	
func stop_music():
	main_menu_theme.stop()
