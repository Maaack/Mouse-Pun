extends HBoxContainer


export(int, 0, 10) var quickslots_available : int = 10

var quickslot_scene = preload("res://Scenes/HUD/Quickslots/Quickslot/Quickslot.tscn")
var slot_array = []

func _ready():
	var quickslot_range = range(quickslots_available)
	slot_array = quickslot_range.duplicate()
	for i in quickslot_range:
		var instance = quickslot_scene.instance()
		add_child(instance)
		instance.slot = i+1
		slot_array[i] = instance

func get_next_empty():
	for quickslot in slot_array:
		if quickslot.quantity == null:
			return quickslot

func find(machine_name_query:String):
	for quickslot in slot_array:
		if quickslot.quantity != null:
			var quantity = quickslot.quantity
			if quantity is AbstractQuantity:
				if quantity.machine_name == machine_name_query:
					return quantity

func add_quantity(quantity:AbstractQuantity):
	if quantity == null:
		return
	var quickslot = find(quantity.machine_name)
	if quickslot == null:
		quickslot = get_next_empty()
	if quickslot == null:
		return
	quickslot.quantity = quantity
