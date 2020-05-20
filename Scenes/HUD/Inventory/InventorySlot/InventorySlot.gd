tool
extends Control

onready var texture_node = $NinePatchRect/MarginContainer/Control/TextureRect
onready var count_node = $NinePatchRect/MarginContainer/Control/Count

export(Resource) var quantity setget set_quantity

func _process(_delta):
	_update_quantity()

func set_quantity(value:AbstractQuantity):
	quantity = value
	_update_quantity()

func _update_quantity():
	if is_instance_valid(quantity) and quantity is AbstractQuantity:
		texture_node.texture = quantity.icon
		count_node.text = str(quantity.quantity)
	else:
		texture_node.texture = null
		count_node.text = ""
