extends Node2D



onready var map_node = $Map

func start_game():
	map_node.start_game()

func get_player():
	return $Map/Interactives/Interactives/Player
