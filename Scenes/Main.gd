extends Control


onready var player_node = $ViewportContainer/Viewport/Game/Map/Interactives/Interactives/Player
onready var hud_node = $HUD
onready var game_node = $ViewportContainer/Viewport/Game

func _ready():
	player_node.connect("stats_updated", self, "_on_Player_body_updated")
	player_node.connect("quickslots_updated", self, "_on_Player_quickslots_updated")
	player_node.connect("quickslot_selected", self, "_on_Player_quickslot_selected")
	hud_node.update_quickslots(player_node.quickslot_manager.slot_array)
	hud_node.update_selected(player_node.quickslot_manager.selected_slot)
	game_node.start_game()

func _on_Player_body_updated(container:AbstractContainer):
	for quantity in container.contents:
		hud_node.add_quantity_to_body_information(quantity)

func _on_Player_quickslots_updated(slots:Array):
	hud_node.update_quickslots(slots)

func _on_Player_quickslot_selected(index:int):
	hud_node.update_selected(index)

