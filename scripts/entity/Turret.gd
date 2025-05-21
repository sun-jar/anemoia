extends Area2D

var in_range: bool = false
var is_shoot: bool = false
var hit_player: bool = false
var player

@onready var projectile_raycast = $RayCast2D

func _ready() -> void:
	player = get_parent().find_child("Player")
	projectile_raycast.enabled = false
 
func _process(_delta: float) -> void:
	if in_range and Input.is_action_just_pressed("wave"):
		if !is_shoot:
			_turret_on()
			is_shoot = true

	if is_shoot:
		_turret_on()
		_check_behind_object()
			# shoot
		# maybe add timer

func _physics_process(delta: float) -> void:
	projectile_raycast.target_position = to_local(player.position)

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		in_range = true
		projectile_raycast.enabled = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_range = false
		is_shoot = false
		
func _turret_on():
	print("shoot")
	if _check_behind_object():
		_apply_damage()
	# Globals.game_data.player_health -= 1
	# health to be adjusted
	# also animations
	
func _check_behind_object() -> bool:
	if projectile_raycast.is_colliding():
		var collider = projectile_raycast.get_collider()
		if collider == player:
			print("no object between")
			return true
		else:
			print(collider)
			print("Object between player and turret.")
			return false
			
	else:
		print("no collisions")
		return true
	
func _apply_damage():
	print("pewpew")
