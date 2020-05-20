extends AbstractUnit


class_name AbstractContainer

const UNLIMITED_SLOTS = -1
const UNLIMITED_QUANTITY = -1.0

export(int) var slot_limit : int = UNLIMITED_SLOTS
export(float) var quantity_limit : float = UNLIMITED_QUANTITY
export(Array, Resource) var contents : Array setget set_contents

func _to_string():
	var to_string = "%s: [" % machine_name
	for content in contents:
		to_string += str(content) + ","
	return to_string + "]"

func set_contents(value:Array):
	if value == null:
		return
	if not _within_limit(value):
		return
	contents = value

func _within_limit(value:Array) -> bool:
	if has_slot_limit():
		if value.size() > slot_limit:
			return false
	if has_quantity_limit():
		if _get_total_quantity(value) > quantity_limit:
			return false
	return true

func _get_total_quantity(quantities:Array) -> float:
	var total_quantity : float = 0.0
	for content in quantities:
		if content is AbstractQuantity:
			total_quantity += content.quantity
	return total_quantity

func has_slot_limit() -> bool:
	return slot_limit != UNLIMITED_SLOTS

func has_quantity_limit() -> bool:
	return quantity_limit != UNLIMITED_QUANTITY

func add_content(value):
	var new_contents = contents.duplicate()
	new_contents.push_back(value)
	set_contents(new_contents)
	return value

func add_quantity(value:AbstractQuantity):
	if value == null:
		return
	var content = find(value.machine_name)
	if is_instance_valid(content) and content is AbstractQuantity:
		content.add(value, true)
		return content
	else:
		return add_content(value)
		
func find(machine_name_query:String):
	for content in contents:
		if content is AbstractUnit and content.machine_name == machine_name_query:
			return content
