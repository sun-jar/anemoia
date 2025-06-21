extends AnimatedSprite2D

signal power_up_complete

# Yang mau di-display sprite power source kondisi di stage berapa?
@export var power_source_display_stage: int
# Power source ini aktif di stage berapa?
@export var power_source_stage: int

var player_body: Node2D = null
var player_camera: Node2D = null
@onready var interact_timer: Timer = $InteractTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_stage = GameManager.player_stage
	if player_stage == power_source_display_stage and power_source_stage == player_stage:
		play("active_" + str(power_source_display_stage))
	elif power_source_stage < GameManager.player_stage:
		play("inactive_" + str(power_source_display_stage))
		$NextStageTrigger/CollisionShape2D.disabled = true
	else:
		play("active_" + str(power_source_display_stage))
		$NextStageTrigger/CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if player_body != null and player_body.name == "Player":
		var camera = player_body.get_node_or_null("Camera2D")
		if event.is_action_pressed("interact"):
			AudioManager.play_shockwave()
			if not interact_timer.is_stopped():
				return
			interact_timer.start()
			camera.start_buildup_shake(3.4, 0.2, 4.0)
		elif event.is_action_released("interact") and not interact_timer.is_stopped():
			AudioManager.stop_shockwave()
			interact_timer.stop()
			camera.stop_buildup_shake()


func _on_next_stage_trigger_body_entered(body: Node2D):
	if (
		body.name == "Player"
		and player_body == null
		and GameManager.player_stage == power_source_stage
	):
		player_body = body


func _on_next_stage_trigger_body_exited(body: Node2D):
	if body.name == "Player" and player_body != null:
		if Input.is_action_pressed("interact"):
			var camera = player_body.get_node_or_null("Camera2D")
			AudioManager.stop_shockwave()
			interact_timer.stop()
			camera.stop_buildup_shake()
		player_body = null


func _on_interact_timer_timeout() -> void:
	if player_body != null and Input.is_action_pressed("interact"):
		GameManager.player_stage += 1
		play("inactive_" + str(power_source_display_stage))
		emit_signal("power_up_complete")
