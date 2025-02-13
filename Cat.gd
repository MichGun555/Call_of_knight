extends KinematicBody2D

onready var dialog = $dialog

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

var start = false
onready var sprite = $AnimatedSprite
onready var leadgeCheckRight = $leadgeCheckRight
onready var leadgeCheckLeft = $leadgeCheckLeft
var speed = 25
var moving_start = true
var moving_stop = true
var on_detected = false

func dialog_NPC():
	dialog.visible = true
	$Timer.start(3)
	yield($Timer, "timeout")
	dialog.text = "meow"
	$Timer.start(1)
	yield($Timer, "timeout")
	dialog.text = "I need some fish"
	dialog.visible = false
		
func _on_Area2D_body_entered(body):
	if body.name == "player":
		dialog_NPC()
		
func _physics_process(delta):
	if moving_start and moving_stop:
		change_speed() 
	var found_wall = is_on_wall()
	var found_leadge = not leadgeCheckLeft.is_colliding() or not leadgeCheckRight.is_colliding()
	
		
	if found_wall or found_leadge:
		direction *= -1
	sprite.flip_h = direction.x < 0
		
	velocity = direction * speed
	move_and_slide(velocity, Vector2.UP)


func change_speed():
	if moving_start:
		moving_start = false
		if moving_stop:
			moving_stop = false
			speed = 0
			sprite.animation = "Idle"
			var stop = int(rand_range(1,8))	
			$Timer.start(stop)
			yield($Timer, "timeout")
			speed = 25
			sprite.animation = "Run"
			var start_move = int(rand_range(7,12))	
			$Timer.start(start_move)
			yield($Timer, "timeout")
			moving_start = true
			moving_stop = true
