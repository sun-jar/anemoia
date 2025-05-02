extends Button

@onready var root_node = get_tree().root.get_node("MainMenu")
var show_focus_outline: bool = false
var hover_stylebox: StyleBoxFlat
var tween: Tween

func _ready():
	var shared_stylebox := root_node.theme.get_stylebox("hover", "Button") as StyleBoxFlat
	focus_mode = Control.FOCUS_ALL
	hover_stylebox = shared_stylebox.duplicate() as StyleBoxFlat
	hover_stylebox.bg_color.a = 0.0
	add_theme_stylebox_override("hover", hover_stylebox)
	
func _gui_input(event):
	if event is InputEventKey and event.pressed:
		show_focus_outline = true
		_update_focus_style()
		
	if event is InputEventMouseButton and event.pressed:
		show_focus_outline = false
		_update_focus_style()

func _on_mouse_entered():
	tween = create_tween()
	tween.tween_method(_set_hover_alpha, hover_stylebox.bg_color.a, 1.0, 0.1)

func _on_mouse_exited():
	tween = create_tween()
	tween.tween_method(_set_hover_alpha, hover_stylebox.bg_color.a, 0.0, 0.1)
	
func _update_focus_style():
	if show_focus_outline:
		var focus_style = root_node.theme.get_stylebox("focus", "Button")
		var font_focus_color = root_node.theme.get_color("font_hover_color", "Button")
		add_theme_stylebox_override("focus", focus_style.duplicate())
		add_theme_color_override("font_focus_color", font_focus_color)
	else:
		var font_focus_color = root_node.theme.get_color("font_color", "Button")
		if font_focus_color:
			add_theme_color_override("font_focus_color", font_focus_color)
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	queue_redraw()

func _set_hover_alpha(alpha: float):
	var color = hover_stylebox.bg_color
	color.a = alpha
	hover_stylebox.bg_color = color
	queue_redraw()
