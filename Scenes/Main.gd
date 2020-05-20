extends Control


onready var player_node = $ViewportContainer/Viewport/Game/Map/Interactives/Interactives/Player
onready var hud_node = $HUD

func _ready():
	hud_node.show_containers(player_node.body_container)
	player_node.connect("quantity_updated", self, "_on_Player_quantity_updated")

func _on_Player_quantity_updated(quantity:AbstractQuantity):
	hud_node.add_quantity_to_quickslot(quantity)
