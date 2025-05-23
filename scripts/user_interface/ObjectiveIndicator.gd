extends Control

@onready var objective_label = $Label

func _ready() -> void:
	modulate.a = 0.0
	GameManager.change_objective.connect(_show_objective)

func _process(delta: float) -> void:
	pass
	
func _show_objective():
	match GameManager.player_stage:
		1:
			objective_label.text = "Find the power source. Follow the high pitch."
			_fade_in()
		2:
			await _fade_out()
			objective_label.text = "Find the next power source. Open locked doors by finding the matching switch."
			_fade_in()
		3:
			await _fade_out()
			objective_label.text = "Find the last power source. You're so close to the end."
			_fade_in()
		4:
			await _fade_out()
			objective_label.text = "Find the exit."
			_fade_in()

func _fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)
	await tween.finished
	
func _fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	await tween.finished
