tool
extends Node2D


class_name Pickup

onready var grid_node = get_parent()

export(Resource) var quantity setget set_quantity

func set_quantity(value:AbstractQuantity):
	quantity = value
	if is_instance_valid(quantity) and quantity is AbstractQuantity:
		$Sprite.texture = quantity.icon
