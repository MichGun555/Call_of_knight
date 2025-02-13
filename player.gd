extends KinematicBody2D

# Маскимальная высота прыжка
export (int) var JUMP_FORCE = -160
# Минимальная высота прыжка
export (int) var JUMP_RELEACE_FORCE = -40
# Максимальная скорость персонажа
export (int) var MAX_SPEED = 75
#величина ускорения персонажа
export (int) var ACCELERATION = 10
#Величина трения персонажа
export (int) var FRICTION = 10
#Сила гравитации
export (int) var GRAVITY = 5
#скорость падения
export (int) var ADDITIONAL_FALL_GRAVITY = 2
# Скорость перемещения персонажа по лестницам
export (int) var CLIMB_SPEED = 50
# Количество жоступных двойных прыжков
export (int) var DOUBLE_JUMP_COUNT = 1
# Перерключатель методов двжения
enum {MOVE,CLIMB}
# Включение в начале игры стандартного перемещения
var state = MOVE 
# Начальное направление персонажа
var velocity = Vector2.ZERO 
var is_attack = false

# подключение анимации персонажа
onready var sprite = $AnimatedSprite
#Колизия персонажа
onready var collision = $CollisionShape2D
# Подключаем хранилище прыжка
onready var JumpBufferTimer = $JumpBufferTimer
# ТАйнмер от отступа
onready var coyotJumpTimer = $coyotJumpTimer
# Проверка лестниц
onready var LadderCheck = $LadderCheck
# Определяем врага
onready var decteted = $Detected/CollisionShape2D
#Cчетчик двойного прыжка
var double_jump = 1
#Возможность прыжка
var buffer_timer = false
# Возможность прыжка с уступа
var coyote_jump = false
# Кол-во здоровья персонажа
var health = 100
#кол-во денег у персонажа
var coin = 0
var on_decteted = false

func _physics_process(delta): 

# Импульс вектора, в котором начинается движение
	var input = Vector2.ZERO
	# Назначение клавиш
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	
	if state == MOVE:
		move_state(input)
	elif state == CLIMB:
		move_climb(input)
		
# функция проверяет положение персонажа на лестнице
func is_on_ladder():
	if not LadderCheck.is_colliding():
		return false
	var collide = LadderCheck.get_collider()
	if not collide is Ladder:
		return false
	return true
# Фунция при обыном движении персонажа
func move_state(input):
	
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
 # Переключить на лазанье
		state = CLIMB
	# Постоянный вызов гравитации
	apply_gravity()
	# Постоянный вызов атаки
	player_attack()
	
	if not horizontal_move(input):
	# включаем режим трения персонажа об поверхность
		apply_friction()
		if not is_attack:
			sprite.animation = "idle"
	if horizontal_move(input):
	# Если персонаж начал движение, то мы включаем посстепенное ускорение
		apply_acceleration(input.x)
		if not is_attack:
			sprite.animation = "run"
		
		
		sprite.flip_h = input.x < 0
		if not sprite.flip_h:
			decteted.position.x = 20
		else:
			decteted.position.x = -19
		
		#Если персонаж на земле
	if can_jump():
		input_jump()
		reset_double_jump()
	else:
		input_releace_jump()
		input_double_jump()
		buffer_double_jump()
		fast_fall()		
		
		if double_jump == 1 and not is_attack:
			sprite.animation = "jump"
		
		if double_jump == 0 and not is_attack: 
			sprite.animation = "jump"
			
		if velocity.y > 0 and not is_attack:
			sprite.animation = "fall"
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	var just_landed = is_on_floor() and was_in_air
	
	if just_landed:
		sprite.animation = "run"
		sprite.frame = 1
		
	var just_left_ground = not is_on_floor() and was_on_floor
	
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyotJumpTimer.start()
		
			
#Функция актаки 
func player_attack():	
	if Input.is_action_just_pressed("ui_accept"):
		is_attack = true
		if is_attack:
			on_dectected_enemy()
			sprite.play("attack")
			yield(sprite,"animation_finished")
			is_attack = false		
			
func on_dectected_enemy():
	decteted.disabled = false
	$Timer.start(0.07)
	yield($Timer, "timeout")
	decteted.disabled = true
	
	

	# данная функция проверяет двигается ли персонаж
func horizontal_move(input):
	return input.x !=0
# При движении по лестницам
func move_climb(input):
	if not is_on_ladder():
		state = MOVE
		
	if input.length() != 0:
		sprite.animation = "climb_run"
	else:
		sprite.animation = "climb_idle"
		
	velocity = input * CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Функция остановки персонажа
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)
func apply_gravity():
	velocity.y += GRAVITY
	velocity.y = min(velocity.y, 300)
# прыжок
func input_jump():
	if Input.is_action_just_pressed("ui_up" ):
		velocity.y = JUMP_FORCE
# функция, которая проверяет возможность прыгнуть
func can_jump():
	return is_on_floor()

#Функция,которая осущиствляет сброс счетчика
func reset_double_jump():
	double_jump = DOUBLE_JUMP_COUNT
	
	#Функция сброса двойного прыжка
func input_releace_jump():
	if Input.is_action_just_pressed("ui_up") and velocity.y < JUMP_RELEACE_FORCE:
			velocity.y = JUMP_RELEACE_FORCE
			
# Функция делающая двойной прыжок
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		velocity.y = JUMP_FORCE
		double_jump -= 1
		
#Данная функция хранит информациюю о двойном прыжке
func buffer_double_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffer_timer = true
		
		
# Фукция делает ускорение падения
func fast_fall():
	if velocity.y > 0:
		velocity.y += ADDITIONAL_FALL_GRAVITY
#Функция получения урона и анимация смерти
func player_damage(dmg:int):
	health -= dmg
	
	player_knock_back()
	blink()	
		
	# Если чисор хдоровья отрицательное, то перезагрузить сцену
	if health <= 0:
		health = 0
		get_tree().reload_current_scene()
# функция отталкивания игрока при получении урона
func player_knock_back():
	if not sprite.flip_h:
		velocity.x = lerp(velocity.x, -MAX_SPEED * 1, 2)
		velocity.y = lerp(0, JUMP_FORCE, 0.5)
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		velocity.x = lerp(velocity.x, MAX_SPEED * 1, 2)
		velocity.y = lerp(0, JUMP_FORCE, 0.5)
		velocity = move_and_slide(velocity, Vector2.UP)
# Мерцание персонажа
func blink():
	$Timer.start(0.05)
	yield($Timer, "timeout")
	$Timer.start(0.07)
	yield($Timer, "timeout")
	sprite.visible = false
	$Timer.start(0.01)
	yield($Timer, "timeout")
	sprite.visible = true
	


func _on_coyotJumpTimer_timeout():
	buffer_timer = false


func _on_JumpBufferTimer_timeout():
	coyote_jump = false


func _on_Detected_body_entered(body):
		
	if "mushroom" in body.name or "Goblin" in body.name:
		$Timer.start(0.03)
		yield($Timer, "timeout")		
		body.destroy_enemy()                                                                                                                                            

func add_coin():
	coin += 1
