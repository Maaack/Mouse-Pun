extends Node2D


class_name Map2D

const COLLIDABLE = 'COLLIDABLE'
const INTERACTIVE = 'INTERACTIVE'
const PICKUPS = 'PICKUPS'
const PASSABLE = 'PASSABLE'

enum CELL_TYPES { EMPTY = -1, NONE }

onready var pickups_grid_node = $Pickups/PickupMap
onready var player_node = $Interactives/Interactives/Player
onready var fog_of_war_grid_node = $FogOfWar/TileMap
onready var interactive_grid_node = $Interactives/Interactives

var intervals_dict : Dictionary = {}
var current_interval_array : Array = []
var current_character : Node2D
var interval_length : int = 1024
var current_interval : int = 0

func start_game():
	fog_of_war_grid_node.visible = true
	player_node.connect("reveal_tile", self, "_on_Player_reveal_tile")
	_start_next_characters_turn()

func _reset_character_turns():
	intervals_dict = {}
	current_interval_array = []
	current_interval = 0
	for node in interactive_grid_node.get_children():
		var speed = 1
		if node.has_method("get_speed"):
			speed = node.get_speed()
		var interval : int = interval_length / pow(2, speed)
		for i in range(0, interval_length, interval):
			if not intervals_dict.has(i):
				intervals_dict[i] = []
			intervals_dict[i].append(node)
	if intervals_dict.has(0):
		current_interval_array = intervals_dict[0]
	return intervals_dict

func _start_next_characters_turn():
	if intervals_dict.size() < 1:
		_reset_character_turns()
		if intervals_dict.size() < 1:
			return
	if current_interval_array.size() == 0:
		current_interval_array = _get_next_interval_array()
		if current_interval_array.size() == 0:
			_reset_character_turns()
			if current_interval_array.size() == 0:
				return
	current_character = current_interval_array.pop_front()
	current_character.connect("turn_taken", self, "_on_Character_turn_taken")
	if current_character.has_method("set_turn_time"):
		var relative_turn_time = player_node.turn_time / pow(2, current_character.get_speed() - player_node.get_speed())
		current_character.set_turn_time(relative_turn_time)
	current_character.start_turn()

func _get_next_interval_array():
	for i in range(current_interval, interval_length+1):
		if intervals_dict.has(i) and intervals_dict[i].size() > 0:
			current_interval = i
			return intervals_dict[i]
	return []

func _on_Character_turn_taken(node:Node2D):
	_start_next_characters_turn()

func is_cellv_type(cell_vector:Vector2, type:String) -> bool:
	for child in get_children():
		if child.is_in_group(type):
			for child_2 in child.get_children():
				if child_2 is TileMap:
					if child_2.get_cellv(cell_vector) != CELL_TYPES.EMPTY:
						return true
	return false


func pickup_from_position(position:Vector2):
	return pickups_grid_node.get_container_at_position(position)

func _on_Player_reveal_tile(tile_position:Vector2):
	fog_of_war_grid_node.set_cellv(tile_position, -1)
	fog_of_war_grid_node.update_bitmask_area(tile_position)
