extends CharacterBody2D

class_name Player

#References
@onready var player_animation = $AnimatedSprite2D
@onready var raycast = $Raycast
@onready var player = $"."
@onready var rope_texture = preload("res://Assets/Textures/Sergio's Hook/Sprite-0002.png")


#Exports
@export var speed = 300.0
@export var jump_force = -350.0
@export var air_drag = 0.3
@export var gravity = 700
@export var swing_speed = 0.975
@export var starting_pos = Vector2(100, 300)

#Locals
var motion: Vector2
var hook_position: Vector2
var hooked: bool = false
var rope_length: float = 500
var current_rope_length: float

func _ready():
	current_rope_length = rope_length

func _physics_process(delta):
	movement(delta)
	hook(delta)
	queue_redraw()

#Handles player movement, gravity & jumping
func movement(delta):
	# Gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		#keep track of player motion for swing mechanic
		motion.y = velocity.y
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
	
	#Airborne Speed Dampening
	if not is_on_floor() and not hooked:
		velocity.x *= (1 - air_drag * delta)
	
	#Keep track of player motion for swing mechanic
	motion.x = velocity.x
	move_and_slide()
	update_animation(direction)
	if position.y > 600:
		GameManager.player_death()

#Updates animations
func update_animation(direction):
	if is_on_floor():
		if direction:
			player_animation.play("Run")
		else:
			player_animation.play("Idle")
	else:
		if velocity.y > 0:
			player_animation.play("Fall")
		elif velocity.y < 0:
			player_animation.play("Jump")

#Handles hook shooting and placement
func hook(delta):
	if hooked:
		hook_swing(delta)
		motion *= swing_speed
	
	#Rotates raycast parent node towards mouse
	raycast.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Left Click"):
		
		#Find the hook's Vector2 if it returns a Vector2
		if get_hook_position():
			hook_position = get_hook_position()
		
		#if there is a hook position (not null)
		if hook_position:
			hooked = true
			current_rope_length = global_position.distance_to(hook_position)
		
	if Input.is_action_just_released("Left Click") and hooked:
		hooked = false
		velocity.y *= -.5
		velocity.x *= 2
		hook_position = Vector2.ZERO

#Returns the Vector2 where raycast is colliding
func get_hook_position():
	if raycast.get_child(0).is_colliding():
		return raycast.get_child(0).get_collision_point()

#Handles hook's swing
func hook_swing(delta):
	
	#Radius of hook relative to player
	var radius: Vector2 = global_position - hook_position
	
	#
	if motion.length() < 0.01 or radius.length() < 10: 
		return
	
	
	var angle = acos(radius.dot(motion) / (radius.length() * motion.length()))
	var radius_velocity = cos(angle) * motion.length()
	motion += radius.normalized() * -radius_velocity
	
	#Keep the player position restricted to the rope's length
	if global_position.distance_to(hook_position) > current_rope_length:
		global_position = hook_position + radius.normalized() * current_rope_length
	
	#
	motion += (hook_position - global_position).normalized() * 15000 * delta

#Draw line
func _draw():
	#Calculate the direction of the rope
	var rope_directon : Vector2 =  hook_position - global_position
	
	#Calculate length
	var rope_length : float = rope_directon.length() + 10
	
	#Calculate angle
	var rope_angle = atan2(rope_directon.y, rope_directon.x)
	
	#Setup Rope Rect
	var rope_rect = Rect2(Vector2.ZERO, Vector2(rope_length, rope_texture.get_height()))
	
	if hooked:
		#Sets the transform for the rope (and all other drawn canvas items)
		draw_set_transform(Vector2.ZERO, rope_angle, Vector2(1, 1))
		#Draws the rope texture
		draw_texture_rect(rope_texture, rope_rect, true, Color(1,1,1,1), false)

func reset_pos():
	position = starting_pos
	velocity = Vector2(0, 0)

