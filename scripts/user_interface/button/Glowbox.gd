extends Button

var show_focus_outline: bool = false
var hover_stylebox: StyleBoxFlat
var tween: Tween

func _ready():
	var base_hover := get_theme_stylebox("hover", "Button") as StyleBoxFlat
	hover_stylebox = base_hover.duplicate()

	hover_stylebox.content_margin_left = 0
	hover_stylebox.content_margin_right = 0
	hover_stylebox.content_margin_top = 6
	hover_stylebox.content_margin_bottom = 0

	hover_stylebox.bg_color.a = 0.0
	hover_stylebox.set_corner_radius_all(0)
	hover_stylebox.set_border_width_all(2)
	hover_stylebox.border_color = Color(1.0, 1.0, 1.0, 0.0)

	add_theme_stylebox_override("hover", hover_stylebox)

	var normal_stylebox = hover_stylebox.duplicate() as StyleBoxFlat
	add_theme_stylebox_override("normal", normal_stylebox)
	
	add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	
	var pressed_stylebox = hover_stylebox.duplicate() as StyleBoxFlat
	pressed_stylebox.bg_color.a = 0.0
	pressed_stylebox.set_border_width_all(0)
	pressed_stylebox.set_corner_radius_all(0)
	hover_stylebox.border_color = Color(1.0, 1.0, 1.0, 0.0)

	add_theme_stylebox_override("pressed", pressed_stylebox)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	tween = create_tween()
	tween.tween_method(_set_border_and_bg_alpha, hover_stylebox.bg_color.a, 1.0, 0.1)

func _on_mouse_exited():
	tween = create_tween()
	tween.tween_method(_set_border_and_bg_alpha, hover_stylebox.bg_color.a, 0.0, 0.1)

func _set_border_and_bg_alpha(alpha: float):
	var border = hover_stylebox.border_color
	border.a = alpha
	hover_stylebox.border_color = border

	var bg = hover_stylebox.bg_color
	bg.a = alpha
	hover_stylebox.bg_color = bg

	queue_redraw()
	
func _gui_input(event):
	if event is InputEventKey and event.pressed:
		show_focus_outline = true
		_update_focus_style()
		
	if event is InputEventMouseButton and event.pressed:
		show_focus_outline = false
		_update_focus_style()
		
func _update_focus_style():
	if show_focus_outline:
		var focus_style = get_theme_stylebox("focus", "Button")
		var font_focus_color = get_theme_color("font_hover_color", "Button")
		add_theme_stylebox_override("focus", focus_style.duplicate())
		add_theme_color_override("font_focus_color", font_focus_color)
	else:
		var font_focus_color = get_theme_color("font_color", "Button")
		if font_focus_color:
			add_theme_color_override("font_focus_color", font_focus_color)
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	queue_redraw()
