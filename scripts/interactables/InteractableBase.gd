extends StaticBody2D

@onready var outline_sprite: Sprite2D = $OutlineSprite
@onready var interaction_area := $Area2D

var is_interactable: bool = false

func _ready():
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))
	_update_outline()

func set_interactable(value: bool) -> void:
	is_interactable = value
	_update_outline()

func _update_outline():
	outline_sprite.visible = is_interactable

	if is_interactable:
		var outline_shader_material := outline_sprite.material as ShaderMaterial
		outline_shader_material.set_shader_parameter("outline_color", Color(1, 1, 1, 1))
		print('works')

func _on_body_entered(body):
	if body.name == "Player":
		set_interactable(true)

func _on_body_exited(body):
	if body.name == "Player":
		set_interactable(false)
		
func interact():
	if is_interactable:
		print("Interactable", self.name)
	else:
		print("Not in range to interact")
