extends TileMap

enum CELL_TYPES { EMPTY = -1, NONE }

var map_node : Map2D

var object_dict : Dictionary = {}

func _ready():
	var cell_id = 0
	for child in get_children():
		cell_id += 1
		var cell_position = world_to_map(child.position)
		add_character_to_dict(cell_id, child)
		set_cellv(cell_position, cell_id)
	# Sketch
	var temp_node = self
	while (not temp_node is Map2D):
		temp_node = temp_node.get_parent()
	map_node = temp_node

func add_character_to_dict(cell_id:int, character:Node2D):
	if character == null:
		return
	if not object_dict.has(cell_id):
		object_dict[cell_id] = character

func get_character_at_position(position:Vector2):
	return get_character_in_cellv(world_to_map(position))

func get_character_in_cellv(cell_vector:Vector2):
	var cell_id = get_cellv(cell_vector)
	if object_dict.has(cell_id):
		return object_dict[cell_id]

func try_move(mover:Node2D, direction:Vector2):
	if not is_instance_valid(mover):
		return
	var start_cell = world_to_map(mover.position)
	var target_cell = start_cell + direction
	var target_cell_id = get_cellv(target_cell)
	if target_cell_id != CELL_TYPES.EMPTY:
		return
	if map_node.is_cellv_type(target_cell, map_node.COLLIDABLE):
		return
	return update_tile_position(start_cell, target_cell)

func try_to_interact(actor:Node2D, direction:Vector2):
	if not is_instance_valid(actor):
		return
	var start_cell = world_to_map(actor.position)
	var target_cell = start_cell + direction
	return get_character_in_cellv(target_cell)

func update_tile_position(start_cell:Vector2, target_cell:Vector2):
	var cell_id = get_cellv(start_cell)
	set_cellv(start_cell, get_cellv(target_cell))
	set_cellv(target_cell, cell_id)
	return map_to_world(target_cell) + (cell_size / 2)
