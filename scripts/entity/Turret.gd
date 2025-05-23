extends Area2D

var in_range: bool = false
var is_shoot: bool = false
var hit_player: bool = false
var player
var in_cooldown: bool = false

@onready var projectile_raycast = $RayCast2D
@onready var cooldown_timer = $Timer

func _ready() -> void:
	player = get_parent().find_child("Player")
	projectile_raycast.enabled = false
 
func _process(_delta: float) -> void:
	if in_range and Input.is_action_just_pressed("wave"):
		if !is_shoot:
			_turret_on()
			is_shoot = true

	if in_range and is_shoot and not in_cooldown:
		_turret_on()

func _physics_process(_delta: float) -> void:
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
	if _check_behind_object():
		_apply_damage()
	
func _check_behind_object() -> bool:
	if projectile_raycast.is_colliding():
		var collider = projectile_raycast.get_collider()
		return (collider == player)
	else:
		return true
	
func _apply_damage():
	player.health -= 1
	GameManager.damage_taken.emit()
	cooldown_timer.start()
	in_cooldown = true
	$AudioStreamPlayer.play()


func _on_timer_timeout() -> void:
	in_cooldown = false
