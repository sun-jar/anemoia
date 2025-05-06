extends Entity

@export var speed = 400

func get_input():
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

func _physics_process(delta: float) -> void:
	if not GameManager.movement_disabled:
		get_input()
		move_and_slide()
