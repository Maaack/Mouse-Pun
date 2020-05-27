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

func _ready():
	player_node.connect("reveal_tile", self, "_on_Player_reveal_tile")

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
