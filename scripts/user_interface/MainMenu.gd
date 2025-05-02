extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = self.create_tween()
	tween.tween_interval(0.5)
	tween.tween_property($ColorRect, "modulate:a", 1.0, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_exit_pressed() -> void:
	get_tree().quit()
