extends Node2D

@export var radius: float = 10.0
@export var expansion_speed: float = 150.0
@export var fade_duration: float = 1.75

@onready var lines = $Line2D

var fade_timer: float = 0.0
var points: Array = []

func generate_circle(radius: float, segments: int = 128):
	$Line2D.clear_points()
	
	points = []
	for i in range(segments + 1):
		var angle = (i / float(segments)) * PI * 2
		var point = Vector2(cos(angle) * radius, sin(angle) * radius)
		points.append(point)
		
	if $Line2D:
		$Line2D.points = points

func update_wave(delta):
	var center = global_position
	var new_points = []
	for i in points:
		var global_point = center + i
		var direction = (global_point - center).normalized()
		var new_pos = global_point + direction * expansion_speed * delta
		new_points.append(new_pos - center)
	
	points = new_points
	$Line2D.points = points

func _ready() -> void:
	generate_circle(radius)

func _process(delta: float) -> void:
	update_wave(delta)
	fade_timer += delta
	
	var alpha = max(0.0, 0.75 - (fade_timer / fade_duration))
	$Line2D.modulate.a = alpha

	if alpha <= 0.0:
		queue_free()
