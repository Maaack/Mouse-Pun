extends Node2D


signal send_message


const MUSHROOM_NAME = 'MUSHROOM'
const NUT_NAME = 'NUT'
const CARROT_NAME = 'CARROT'

onready var map_node = $Map

var picked_up_objects = 0
var picked_up_nuts = 0
var picked_up_carrots = 0

func start_game():
	map_node.start_game()
	setup_player_events()
	_send_message("You emerge from your lair, weak, and starving.")
	_send_message("Your vision is blurry, but you see food nearby!")

func setup_player_events():
	var player = $Map/Interactives/Interactives/Player
	player.connect("picked_up", self, "_on_Player_picked_up")

func get_player():
	return $Map/Interactives/Interactives/Player

func _send_message(message:String):
	emit_signal("send_message", message)

func _on_Player_picked_up(item:AbstractUnit):
	_send_message("You picked up a %s." % [item.readable_name])
	picked_up_objects += 1
	if picked_up_objects == 1:
		_send_message("You should eat that by pressing E.")
	match(item.machine_name):
		NUT_NAME:
			picked_up_nuts += 1
			if picked_up_nuts == 1:
				_send_message("Nuts have a lot of fiber. They'll help digest food faster.")
		CARROT_NAME:
			picked_up_carrots += 1
			if picked_up_nuts == 1:
				_send_message("Carrots have vitamins that help your eyes. Fiber, too!")
