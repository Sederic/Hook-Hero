extends Node

var root
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	root = get_tree().root
	player = get_node("/root/Level/SubViewportContainer/SubViewport/Player")

func player_death():
	$SubViewportContainer/CanvasLayer/UI.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
