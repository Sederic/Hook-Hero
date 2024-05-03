extends Node

var root
var player
var ui
var level
# Called when the node enters the scene tree for the first time.
func _ready():
	root = get_tree().root
	print(root.get_children())
	level = get_node("/root/Root/SubViewportContainer/SubViewport/Level")
	ui = get_node("/root/Root/SubViewportContainer/CanvasLayer/UI")
	player = level.get_children()[0]
	ui.show()
	level.set_process_mode(PROCESS_MODE_DISABLED)
	debug()

func player_death():
	ui.show()
	level.set_process_mode(PROCESS_MODE_DISABLED)
	player.reset_pos()

func debug():
	ui.hide()
	get_node("/root/Root/SubViewportContainer/SubViewport/TileMap").queue_free()
	level.set_process_mode(PROCESS_MODE_INHERIT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
