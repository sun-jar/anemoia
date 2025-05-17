extends Node2D

@onready var main_menu_theme = $MainMenuTheme
@onready var shockwave_sfx = $ShockwaveSFX
@onready var room_tone = $RoomToneSFX

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
	
func play_shockwave():
	shockwave_sfx.play()
	
func stop_shockwave():
	shockwave_sfx.stop()
	
func play_room_tone():
	room_tone.play()
	var db_tween = create_tween()
	db_tween.tween_property(room_tone, "volume_db", 1.0, 1.0)
	
func stop_room_tone():
	room_tone.stop()
	room_tone.volume_db = -50.0
