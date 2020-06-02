var quickslots_available : int = 10
var slot_array = []
var selected_slot = 0

func _init():
	var quickslot_range = range(quickslots_available)
	slot_array = quickslot_range.duplicate()
	for i in quickslot_range:
		slot_array[i] = null

func get_next_empty_index():
	for i in range(slot_array.size()):
		if slot_array[i] == null:
			return i

func find(machine_name_query:String):
	for quantity in slot_array:
		if is_instance_valid(quantity) and quantity is AbstractQuantity:
			if quantity.machine_name == machine_name_query:
				return quantity

func add_quantity(quantity:AbstractQuantity):
	if quantity == null:
		return
	var found_quantity = find(quantity.machine_name)
	if is_instance_valid(found_quantity):
		return
	var index = get_next_empty_index()
	if index == null:
		return		
	slot_array[index] = quantity

func select_slot(value:int):
	if value < 0 or value >= slot_array.size():
		return
	selected_slot = value

func get_selected_quantity():
	return slot_array[selected_slot]
