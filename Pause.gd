extends Node2D

onready var Resume = $CanvasLayer/Resume
onready var Main = $CanvasLayer/Main
var open = false

func _process(delta):
	if Input.is_action_just_pressed("P") and not open:
		Resume.visible = true
		Main.visible = true
		open = true
	else:
		Resume.visible = false
		Main.visible = false
		open = false
