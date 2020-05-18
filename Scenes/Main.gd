extends Control


onready var player_node = $ViewportContainer/Viewport/Game/Map/Interactives/Interactives/Player
onready var hud_node = $HUD

func _ready():
	hud_node.show_containers(player_node.body_container)
