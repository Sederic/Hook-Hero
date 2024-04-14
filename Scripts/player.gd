extends CharacterBody2D

class_name Player

#References
@onready var player_animation = $AnimatedSprite2D
@onready var raycast = $Raycast

#Exports
@export var speed = 300.0
@export var jump_force = -350.0
@export var air_drag = 0.3
@export var gravity = 700
@export var swing_speed = 0.975

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
		#Find the hook's Vector2
		hook_position = get_hook_position()
		
		#if there is a hook position (not null)
		if hook_position:
			hooked = true
			current_rope_length = global_position.distance_to(hook_position)
		
	if Input.is_action_just_released("Left Click") and hooked:
		hooked = false
		velocity.y *= -.5
		velocity.x *= 2

#Returns the Vector2 where raycast is colliding
func get_hook_position():
	for ray in raycast.get_children():
		if ray.is_colliding():
			return ray.get_collision_point()

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

func _draw():
	
	var pos = global_position
	
	if hooked:
		#This should be replaced with a DrawTextureMesh later 
		draw_line(Vector2(0, 0), to_local(hook_position), Color(.56, .44, .00), 2 , true)
	else:
		return 
	
	
	var colliding: bool
	var point_of_collision: Vector2
	
	#Check if any of the raycasts collided
	for child in raycast.get_children():
		if child is RayCast2D:
			if child.is_colliding():
				colliding = true
				point_of_collision = child.get_collision_point()
			else:
				colliding = false
	
	#if colliding and pos.distance_to(point_of_collision) < rope_length:
		#draw_line(Vector2(0, 0), to_local(point_of_collision), Color("WHITE", 0.25), 3 , true)
