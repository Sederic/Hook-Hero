extends CharacterBody2D

class_name Player

#References
@onready var player_animation = $AnimatedSprite2D
@onready var player = $"."

#Variables
@export var speed = 300.0
@export var jump_force = -350.0
@export var gravity = 700

var starting_pos = Vector2(100, 300)

func _physics_process(delta):
	movement(delta)

#Handles player movement, gravity & jumping
func movement(delta):
		# Gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 500:
			velocity.y = 500
	
	# Jump.
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = jump_force

	#Movement
	var direction = Input.get_axis("Left", "Right")
	# If moving:
	if direction:
		#Flip sprite if player is moving other direction
		player_animation.flip_h = (direction == -1)
	
	#Give player velocity towards direction
	velocity.x = direction * speed
	move_and_slide()
	update_animation(direction)

#Updates animations
func update_animation(direction):
	if is_on_floor():
		if direction:
			player_animation.play("Run")
		else:
			#player_animation.play("Idle")
			player_animation.play("test")
	else:
		if velocity.y > 0:
			player_animation.play("Fall")
		elif velocity.y < 0:
			player_animation.play("Jump")

func reset_pos():
	position = starting_pos

