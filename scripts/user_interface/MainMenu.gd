extends Control

@onready var hover_stylebox := theme.get_stylebox("hover", "Button") as StyleBoxFlat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = self.create_tween()
	tween.tween_interval(0.5)
	tween.tween_property($ColorRect, "modulate:a", 1.0, 1.0)
	hover_stylebox.bg_color.a = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _on_exit_pressed() -> void:
	get_tree().quit()
