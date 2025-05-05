extends Node2D

@onready var nameless_sleep = preload("res://assets/entity/nameless_sleep_1.png")
@onready var nameless_awake = preload("res://assets/entity/nameless_1.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval($InitialBeep.stream.get_length()-2.73)
	$InitialBeep.play()
	await tween.finished
	$PlayerPLACEHOLDER.visible = true
	$Beep1.play()
	await $Beep1.finished
	$Beep2.play()
	await $Beep2.finished
	$Beep3.play()
	await $Beep3.finished
	tween = create_tween()
	tween.tween_interval(2)
	await tween.finished
	$PlayerPLACEHOLDER/Sprite2D.texture = nameless_awake
	Dialogic.start("timeline")
	get_viewport().set_input_as_handled()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
