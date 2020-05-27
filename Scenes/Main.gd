extends Control


onready var player_node = $ViewportContainer/Viewport/Game/Map/Interactives/Interactives/Player
onready var hud_node = $HUD

func _ready():
	hud_node.update_body_container(player_node.body)
	player_node.connect("quantity_updated", self, "_on_Player_quantity_updated")
	player_node.connect("body_updated", self, "_on_Player_body_updated")

func _on_Player_body_updated(container:AbstractContainer):
	for quantity in container.quantities:
		hud_node.add_quantity_to_body_information(quantity)

func _on_Player_quantity_updated(quantity:AbstractQuantity):
	hud_node.add_quantity_to_quickslot(quantity)
