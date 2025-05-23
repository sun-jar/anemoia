extends Entity
signal trigger_wave

enum StableState { IDLE, MOVE }
enum State {
	IDLE      = 0,
	MOVE      = 1,
	T_IM      = 2,  # Transition Idle→Move
	T_MI      = 3   # Transition Move→Idle
}

@export var speed = 500
@export var wave_cooldown = 1.0

@onready var anim = $AnimationPlayer
var current_anim = ""
var temp_stage

var current_state = State.IDLE
var requested_state = StableState.IDLE
var last_direction = Vector2.ZERO

var last_wave_time: float

var idle_timer := 0.0
const CUTOFF_DURATION := 0.15
var move_loop_started := false

var current_interactable = null

@onready var healthbar = $CanvasLayer/HealthBar

func _ready() -> void:
	healthbar.init_health(self.health)
	GameManager.damage_taken.connect(_set_health)

func _physics_process(delta: float) -> void:
	temp_stage = 3 if GameManager.player_stage > 3 else GameManager.player_stage
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
		_ensure_play("move" + str(temp_stage) + "_u")
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
			_ensure_play("idle" + str(temp_stage))
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
			
	if Input.is_action_just_pressed("interact"):
		if current_interactable != null:
			current_interactable.interact()

func _start_transition_to_move():
	current_state = State.T_IM
	anim.play("idle" + str(temp_stage) + "_move")
	current_anim = "idle" + str(temp_stage) + "_move"

func _start_transition_to_idle():
	current_state = State.T_MI
	anim.play("move" + str(temp_stage) + "_idle")
	current_anim = "move" + str(temp_stage) + "_idle"

func _play_move_loop(direction):
	move_loop_started = true
	var anim_name := ""
	if direction.y < 0 or direction.y > 0:
		anim_name = "move" + str(temp_stage) + "_u"
	elif direction.x < 0:
		anim_name = "move" + str(temp_stage) + "_l"
	elif direction.x > 0:
		anim_name = "move" + str(temp_stage) + "_r"
	else:
		anim_name = "move" + str(temp_stage) + "_u"
		move_loop_started = false
	_ensure_play(anim_name)

func _ensure_play(anim_name: String) -> void:
	if current_anim != anim_name:
		anim.play(anim_name)
		current_anim = anim_name

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	match current_state:
		State.T_IM:
			current_state = State.MOVE
			_play_move_loop(last_direction)
		State.T_MI:
			current_state = State.IDLE
			_ensure_play("idle" + str(temp_stage))
		_:
			return

	if requested_state == StableState.MOVE and current_state == State.IDLE:
		_start_transition_to_move()
	elif requested_state == StableState.IDLE and current_state == State.MOVE:
		_start_transition_to_idle()

func _set_health():
	healthbar.health = health
		
func _on_Area2D_body_entered(body):
	if body.is_in_group("interactables"):
		current_interactable = body

func _on_Area2D_body_exited(body):
	if body == current_interactable:
		current_interactable = null
