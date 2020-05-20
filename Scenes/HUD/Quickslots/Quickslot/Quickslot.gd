extends Control


export(int,0,10) var slot : int setget set_slot
export(Resource) var quantity setget set_quantity

func set_slot(value:int):
	$Label.text = str(value)

func set_quantity(value:AbstractQuantity):
	quantity = value
	$InventorySlot.quantity = quantity
