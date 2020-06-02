extends Control


onready var hud_container_node = $HUDContainer
onready var hud_node = $HUDContainer/HUD
onready var game_container_node = $ViewportContainer/Viewport
onready var game_node = $ViewportContainer/Viewport/Game
onready var death_screen_node = $CenterContainer/Control/DeathScreen

var hud_scene = preload("res://Scenes/HUD/HUD.tscn")
var game_scene = preload("res://Scenes/Game/Game.tscn")

func _ready():
	_start_ready_game()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _reset_game():
	game_node.queue_free()
	hud_node.queue_free()
	var new_game_instance = game_scene.instance()
	var new_hud_instance = hud_scene.instance()
	game_container_node.add_child(new_game_instance)
	hud_container_node.add_child(new_hud_instance)
	game_node = new_game_instance
	hud_node = new_hud_instance
	_start_ready_game()

func _start_ready_game():
	var player_node = game_node.get_player()
	player_node.connect("stats_updated", self, "_on_Player_body_updated")
	player_node.connect("quickslots_updated", self, "_on_Player_quickslots_updated")
	player_node.connect("quickslot_selected", self, "_on_Player_quickslot_selected")
	player_node.connect("death", self, "_on_Player_death")
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

func _on_Player_death():
	death_screen_node.show()

func _on_DeathScreen_restart_game():
	death_screen_node.hide()
	_reset_game()
