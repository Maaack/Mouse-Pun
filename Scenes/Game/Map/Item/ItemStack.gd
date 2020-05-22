extends Item


class_name ItemStack

signal picked_up
signal split

export(Resource) var quantity setget set_quantity

func set_quantity(value:AbstractQuantity):
	quantity = value.duplicate()
	if is_instance_valid(quantity) and quantity is AbstractQuantity:
		$Sprite.texture = quantity.icon

func split(amount:int):
	if amount == null or unit == null:
		return
	if unit is AbstractQuantity:
		var split_quantity : AbstractQuantity = unit.split(amount)
		emit_signal("split", split_quantity, unit)
		return split_quantity

func pickup():
	if is_instance_valid(self):
		queue_free()
		emit_signal("picked_up", quantity)
		return quantity
