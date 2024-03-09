extends CharacterBody2D

@export var SPEED = 200.0
@export var ACCELERATE = 20.0
@export var JUMP_POWER = 350.0
@export var JUMP_TIME = 0.3
@export var Playing = true
var jumping = false
var canJump = true
var coyote = false
var accelerate = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var curgravity

func jumpCancel() -> void:
	#Possible holding jump button time
	await get_tree().create_timer(JUMP_TIME).timeout
	if jumping:
		jumping = false

func Coyote() -> void:
	#Name says everything ig. Lets you jump after leaving platform
	coyote = true
	await get_tree().create_timer(0.03).timeout
	if canJump:
		canJump = false
	coyote = false

func _physics_process(delta):
	if not Playing:
		return
	
	#Jumping handle
	if jumping:
		canJump = false
		curgravity = 0
		velocity.y = -JUMP_POWER
	else:
		if not is_on_floor():
			curgravity = gravity
			if not coyote:
				Coyote()
	
	#Back jump ability after landing
	if is_on_floor() and not canJump:
		canJump = true
	
	velocity.y += curgravity * delta
	
	#Input
	if Input.is_action_just_pressed("jump") and not jumping and canJump:
		jumping = true
		jumpCancel()
	if Input.is_action_just_released("jump") and jumping:
		jumping = false
	
	#Almost standart moving, but better. Lets you slide and makes all moves smoother
	var direction = Input.get_axis("left", "right")
	if direction < 0:
		if accelerate > -SPEED:
			accelerate -= ACCELERATE
	if direction == 0:
		if accelerate != 0:
			if accelerate > 0:
				accelerate -= ACCELERATE
			else:
				accelerate += ACCELERATE
	if direction > 0:
		if accelerate < SPEED:
			accelerate += ACCELERATE
	velocity.x = accelerate
	
	move_and_slide()
