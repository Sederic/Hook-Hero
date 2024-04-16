extends Node

var root
var player
var ui
# Called when the node enters the scene tree for the first time.
func _ready():
	root = get_tree().root
	player = get_node("/root/Level/SubViewportContainer/SubViewport/Player")
	ui = get_node("/root/Level/SubViewportContainer/CanvasLayer/UI")
	ui.show()
	debug()

func player_death():
	ui.show()
	player.reset_pos()

func debug():
	get_node("/root/Level/SubViewportContainer/SubViewport/TileMap").queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
