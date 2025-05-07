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
