extends Node

# Most of these are still JOROK™ Certified.
# Just for the sake of seeing it working
var game_started: bool = false
var player_stage: int = 1
var movement_disabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func start_dialogue(title: String) -> void:
	movement_disabled = true
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(title)
	
func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	await get_tree().create_timer(0.1).timeout
	movement_disabled = false
	
	
func save_game(game):
	var player = game.get_node("Player")
	var game_data = {
		"game_started": GameManager.game_started,
		
		"player_speed": player.speed,
		"player_wave_cooldown": player.wave_cooldown,
		"player_health": player.health,
		
		"player_x": player.position.x,
		"player_y": player.position.y
	}

	var json_string = JSON.stringify(game_data)
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	
	save_file.store_line(json_string)
	save_file.close()
	
func load_game():
	var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json_string = save_file.get_as_text()
	save_file.close()
	
	var game_data = JSON.parse_string(json_string)
	
	Globals.game_data = game_data
	GameManager.game_started = game_data.get("game_started", false)
	
