extends StaticBody2D
@export var object_id: String

signal interacted

func _on_interact():
	print("Interacted with: ", object_id)
	emit_signal("interacted", object_id)
