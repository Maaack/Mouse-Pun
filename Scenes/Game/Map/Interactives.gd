extends TileMap

enum CELL_TYPES { EMPTY = -1, NONE, PLAYER, OBSTACLE}

var map_node : Map2D

func _ready():
	for child in get_children():
		set_cellv(world_to_map(child.position), CELL_TYPES.PLAYER)
	# Sketch
	var temp_node = self
	while (not temp_node is Map2D):
		temp_node = temp_node.get_parent()
	map_node = temp_node

func try_move(mover:Node2D, direction:Vector2):
	if not is_instance_valid(mover):
		return
	var start_cell = world_to_map(mover.position)
	var target_cell = start_cell + direction
	var target_tile_type = get_cellv(target_cell)
	if target_tile_type != CELL_TYPES.EMPTY:
		return
	if map_node.is_cellv_type(target_cell, map_node.COLLIDABLE):
		return
	return update_tile_position(CELL_TYPES.PLAYER, start_cell, target_cell)

func update_tile_position(type:int, start_cell:Vector2, target_cell:Vector2):
	set_cellv(target_cell, type)
	set_cellv(start_cell, CELL_TYPES.EMPTY)
	return map_to_world(target_cell) + (cell_size / 2)
