extends AnimatedSprite2D

@export_enum("l", "r", "u") var _enum_index
@export var disabled = true
@export var id = -1

@onready var enum_name = ["l", "r", "u"][_enum_index]
		
func toggle_enable(stage):
	disabled = false
	play(stage + enum_name + "_blink")
	
func toggle_disable(stage):
	disabled = true
	play(stage + enum_name + "_deactivated")
