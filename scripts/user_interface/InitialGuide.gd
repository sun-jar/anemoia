extends Panel

var advanced = false
var last_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player = get_parent()
	if not advanced:
		last_pos = player.global_position
	else:
		if player.global_position != last_pos:
			queue_free()
	
func show_initial_guide():
	visible = true
		
func advance_guide():
	advanced = true
	$MarginContainer/Label.text = "Press WASD to move around."
