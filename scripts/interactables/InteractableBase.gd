extends StaticBody2D

@export var interact_text: String = "*static*"

@onready var sprite: Sprite2D = $Sprite
@onready var shader_material = sprite.material
@onready var interaction_area := $Area2D

var is_interactable: bool = false

func _ready():
	_update_outline()

func set_interactable(value: bool) -> void:
	is_interactable = value
	_update_outline()

func _update_outline():
	if shader_material:
		shader_material.set_shader_parameter("show_outline", is_interactable)

func _on_body_entered(body):
	if body.name == "Player":
		set_interactable(true)

func _on_body_exited(body):
	if body.name == "Player":
		set_interactable(false)
		
func interact():
	if is_interactable:
		print(interact_text, self.name)
	else:
		print("Not in range to interact")
