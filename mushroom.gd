extends KinematicBody2D

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var leadgeCheckRight = $leadgeCheckRight
onready var leadgeCheckLeft = $leadgeCheckLeft
onready var DetectedPlayer = $Detectet/CollisionShape2D
var speed = 25
var moving_start = true
var moving_stop = true
var on_detected = false
func _physics_process(delta):
	if moving_start and moving_stop:
		change_speed() 
	var found_wall = is_on_wall()
	var found_leadge = not leadgeCheckLeft.is_colliding() or not leadgeCheckRight.is_colliding()
	
		
	if found_wall or found_leadge:
		direction *= -1
		DetectedPlayer.position.x *= -1
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
			var stop = int(rand_range(1,4))	
			$Timer.start(stop)
			yield($Timer, "timeout")
			speed = 20
			sprite.animation = "Run"
			var start_move = int(rand_range(7,12))	
			$Timer.start(start_move)
			yield($Timer, "timeout") 
			moving_start = true
			moving_stop = true
func _on_Area2D_body_entered(body):
	if body.name == "player":
		var damage = int(rand_range(12,27))			
		body.player_damage(damage)
		


func _on_Detectet_body_entered(body):
	if body.name == "player":
		speed = 0
		on_detected = true
		sprite.animation = "Attack"
		$Timer.start(0.7)
		yield($Timer, "timeout")
		if on_detected:
			var damage = int(rand_range(21,55))	
			body.player_damage(damage)
		sprite.animation = "Idle"

func _on_Detectet_body_exited(body):
	if body.name == "player":
		speed = 25
		on_detected = false
		DetectedPlayer.disabled = true
		$Timer.start(1)
		yield($Timer, "timeout")
		DetectedPlayer.disabled = false


func destroy_enemy():
	queue_free()
