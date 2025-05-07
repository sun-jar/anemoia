extends Entity

signal trigger_wave

@export var speed = 400
@export var wave_cooldown = 1.0

var last_wave_time: float

func get_input():
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

func _physics_process(_delta: float) -> void:
	if not GameManager.movement_disabled:
		get_input()
		move_and_slide()
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("wave"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_wave_time >= wave_cooldown:
			emit_signal("trigger_wave")
			last_wave_time = current_time
		
		
