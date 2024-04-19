extends Sprite2D

var game_manager

@export var starting_pos = Vector2(300, 400)
# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_node("/root/GameManager")
	position = starting_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
