extends Node

signal dialogue_finished

# Most of these are still JOROK™ Certified.
# Just for the sake of seeing it working
var game_started: bool = false
var player_stage: int = 1
var movement_disabled: bool = true

var shown_one_time_dialogues = {
	"guide": false
}
var last_played_dialogue


var closed_doors = [false, false, false, false, false, false, false, false, false, false, false, false]

var door0 = [Vector2i(-3, -61), Vector2i(-3, -62), Vector2i(-3, -63), Vector2i(-3, -64)]
var doors = [null, Vector2i(55, -46), Vector2i(62, -17), Vector2i(59, 7), Vector2i(33, 69), Vector2i(68, 73), Vector2i(-42, 69), null, Vector2i(30, -6), Vector2i(32, 11), Vector2i(-8, 49), Vector2i(56, 43)]

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
		"player_y": player.position.y,
		
		"closed_doors": closed_doors 
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
	GameManager.player_stage = game_data.player_stage
	GameManager.closed_doors = game_data.closed_doors
	
func reset_game(player_node):
	player_stage = 1
	game_started = false
	movement_disabled = true
	
	player_node.health = 100
	player_node.speed = 400
	player_node.wave_cooldown = 1.0
