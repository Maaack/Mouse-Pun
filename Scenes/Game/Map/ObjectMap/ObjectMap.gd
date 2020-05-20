extends TileMap


var object_dict : Dictionary = {}

func _ready():
	for child in get_children():
		var cell_position = world_to_map(child.position)
		if child is Pickup:
			add_pickup_to_dict(cell_position, child)

func add_pickup_to_dict(cell_vector:Vector2, pickup:Pickup):
	var contents : Array
	if not object_dict.has(cell_vector):
		contents = []
		object_dict[cell_vector] = contents
	else:
		contents = object_dict[cell_vector]
	contents.push_back(pickup)

func add_quantity_to_cellv(cell_vector:Vector2, quantity:AbstractQuantity):
	var container
	if not object_dict.has(cell_vector):
		container = AbstractContainer.new()
		object_dict[cell_vector] = container
	else:
		container = object_dict[cell_vector]
	if container is AbstractContainer:
		container.add_content(quantity)

func get_container_at_position(position:Vector2) -> AbstractContainer:
	return get_container_in_cellv(world_to_map(position))

func get_container_in_cellv(cell_vector:Vector2) -> AbstractContainer:
	var container = AbstractContainer.new()
	if object_dict.has(cell_vector):
		var contents : Array = object_dict[cell_vector]
		if contents != null:
			for content in contents:
				if is_instance_valid(content) and content is Pickup:
					container.add_content(content.quantity)
					content.queue_free()
	return container
