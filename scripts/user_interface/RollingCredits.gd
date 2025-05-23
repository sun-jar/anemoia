extends Control

@onready var credits_text = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var load_tween = create_tween()
	load_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	await load_tween.finished
	var scroll_tween = create_tween()
	scroll_tween.tween_property(credits_text, "position:y", -5000.0, 60)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_pressed() -> void:
	queue_free()
