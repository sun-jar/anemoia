extends Control

@onready var objective_label = $Label

func _ready() -> void:
	visible = false
	GameManager.change_stage.connect(_show_objective)

func _process(delta: float) -> void:
	pass
	
func _show_objective():
	match GameManager.player_stage:
		1:
			objective_label.text = "Find the power source. Follow the high pitch."
		2:
			objective_label.text = "Find the power source. Open locked doors by finding the matching switch."
		3:
			objective_label.text = ""
