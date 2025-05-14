extends Entity
signal trigger_wave

enum StableState { IDLE, MOVE }
enum State { 
	IDLE      = 0, 
	MOVE      = 1, 
	T_IM      = 2,  # Transition Idle→Move
	T_MI      = 3   # Transition Move→Idle
}

@export var speed = 400
@export var wave_cooldown = 1.0

@onready var anim = $AnimatedSprite

var current_state = State.IDLE
var requested_state = StableState.IDLE
var last_direction = Vector2.ZERO

var last_wave_time: float
var stage: int = 1

var idle_timer := 0.0
const CUTOFF_DURATION := 0.15
var move_loop_started := false

func _physics_process(delta: float) -> void:
	if GameManager.movement_disabled:
		return

	var dir = Input.get_vector("left","right","up","down")
	last_direction = dir
	velocity = dir * speed
	move_and_slide()

	if dir == Vector2.ZERO:
		idle_timer += delta
	else:
		idle_timer = 0.0

	if dir != Vector2.ZERO:
		requested_state = StableState.MOVE
		
	elif idle_timer < CUTOFF_DURATION and move_loop_started:
		_ensure_play("move" + str(stage) + "_u")
	elif idle_timer >= CUTOFF_DURATION:
		requested_state = StableState.IDLE

	if current_state in [State.T_IM, State.T_MI]:
		return

	if requested_state == StableState.MOVE and current_state == State.IDLE:
		_start_transition_to_move()
	elif requested_state == StableState.IDLE and current_state == State.MOVE:
		_start_transition_to_idle()
	else:
		if current_state == State.IDLE:
			_ensure_play("idle" + str(stage))
		else:
			_play_move_loop(last_direction)

func _process(_delta: float) -> void:
	if GameManager.movement_disabled:
		return

	if Input.is_action_just_pressed("wave"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_wave_time >= wave_cooldown:
			emit_signal("trigger_wave")
			last_wave_time = current_time

func _start_transition_to_move():
	current_state = State.T_IM
	anim.play("idle" + str(stage) + "_move")

func _start_transition_to_idle():
	current_state = State.T_MI
	anim.play("move" + str(stage) + "_idle")

func _play_move_loop(direction):
	move_loop_started = true
	var anim_name := ""
	if direction.y < 0 or direction.y > 0:
		anim_name = "move" + str(stage) + "_u"
	elif direction.x < 0:
		anim_name = "move" + str(stage) + "_l"
	elif direction.x > 0:
		anim_name = "move" + str(stage) + "_r"
	else:
		anim_name = "move" + str(stage) + "_u"
		move_loop_started = false
	_ensure_play(anim_name)

func _ensure_play(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func _on_animated_sprite_animation_finished():
	match current_state:
		State.T_IM:
			current_state = State.MOVE
			_play_move_loop(last_direction)
		State.T_MI:
			current_state = State.IDLE
			_ensure_play("idle" + str(stage))
		_:
			return

	if requested_state == StableState.MOVE and current_state == State.IDLE:
		_start_transition_to_move()
	elif requested_state == StableState.IDLE and current_state == State.MOVE:
		_start_transition_to_idle()
