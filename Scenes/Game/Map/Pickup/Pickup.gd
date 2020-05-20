tool
extends Node2D


class_name Pickup

export(Resource) var quantity setget set_quantity

func set_quantity(value:AbstractQuantity):
	quantity = value.duplicate()
	if is_instance_valid(quantity) and quantity is AbstractQuantity:
		$Sprite.texture = quantity.icon
