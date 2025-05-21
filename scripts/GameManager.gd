extends Node

signal dialogue_finished
signal damage_taken

# Most of these are still JOROK™ Certified.
# Just for the sake of seeing it working
var game_started: bool = false
var player_stage: int = 1
var movement_disabled: bool = true

var shown_one_time_dialogues = {
	"guide": false
}
var last_played_dialogue

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
	last_played_dialogue = title
	
func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	if shown_one_time_dialogues.has(last_played_dialogue):
		shown_one_time_dialogues[last_played_dialogue] = true
	await get_tree().create_timer(0.1).timeout
	movement_disabled = false
	emit_signal("dialogue_finished")
	
	
func save_game(game):
	var player = game.get_node("Player")
	var game_data = {
		"game_started": GameManager.game_started,
		"shown_one_time_dialogues": shown_one_time_dialogues,
		
		"player_stage": GameManager.player_stage,
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
	GameManager.shown_one_time_dialogues = game_data.get("shown_one_time_dialogues", {})
	
func reset_game(player_node):
	player_stage = 1
	game_started = false
	movement_disabled = true
	
	player_node.health = 100
	player_node.speed = 400
	player_node.wave_cooldown = 1.0
