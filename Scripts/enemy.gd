extends Sprite2D

var game_manager
# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_node("/root/GameManager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Area2D.overlaps_area(game_manager.player.get_children()[0]):
		game_manager.player_death()