extends Area2D

var in_range: bool = false
var is_shoot: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if in_range and Input.is_action_just_pressed("wave"):
		is_shoot = true
		
	if is_shoot:
		_turret_on()
		# maybe add timer

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_range = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_range = false
		is_shoot = false
		
func _turret_on():
	pass
	# Globals.game_data.player_health -= 1
	# health to be adjusted
	# also animations
