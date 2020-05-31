extends Control


onready var inventory_slot_node = $InventorySlot
onready var selected_node = $Selected
onready var label_node = $Label

export(int,0,10) var slot : int setget set_slot
export(Resource) var quantity setget set_quantity
export(bool) var selected setget set_selected

func set_slot(value:int):
	slot = value
	if is_instance_valid(label_node):
		label_node.text = str(slot)

func set_quantity(value:AbstractQuantity):
	quantity = value
	if is_instance_valid(inventory_slot_node):
		inventory_slot_node.quantity = quantity

func set_selected(value:bool):
	selected = value
	if is_instance_valid(selected_node):
		selected_node.visible = selected
