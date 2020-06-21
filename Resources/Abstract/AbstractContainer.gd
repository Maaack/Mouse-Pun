extends AbstractUnit


class_name AbstractContainer

const TOTAL_QUANTITY = 'TOTAL_QUANTITY'

export(Array, Resource) var contents : Array setget set_contents

var quantities : Array = []
var total_quantity : AbstractQuantity

func _to_string():
	var to_string = "%s: [" % machine_name
	for content in contents:
		to_string += str(content) + ","
	return to_string + "]"

func set_contents(value:Array):
	if value == null:
		return
	contents = _return_valid_array(value)
	update_quantities()

func _return_valid_array(array:Array):
	var final_array : Array = []
	for unit in array:
		if unit is AbstractUnit:
			final_array.append(unit.duplicate())
	return final_array

func _reset_quantities():
	if total_quantity == null:
		total_quantity = AbstractQuantity.new()
		total_quantity.machine_name = TOTAL_QUANTITY
	total_quantity.quantity = 0
	for quantity in quantities:
		if quantity is AbstractQuantity:
			quantity.quantity = 0

func update_quantities():
	_reset_quantities()
	for content in contents:
		if content is AbstractUnit:
			add_to_quantity(content)
			add_to_total(content)

func _get_quantity_to_add(content:AbstractUnit):
	if content is AbstractQuantity:
		return content.quantity
	return 1

func add_to_quantity(content:AbstractUnit):
	var quantity_to_add = _get_quantity_to_add(content)
	var quantity : AbstractQuantity
	quantity = find_quantity(content.machine_name)
	if quantity:
		quantity.quantity += quantity_to_add
	else:
		quantity = AbstractQuantity.new()
		quantity.copy_from(content)
		quantity.quantity = quantity_to_add
		quantities.append(quantity)
	return quantity

func add_to_total(content:AbstractUnit):
	var quantity_to_add = _get_quantity_to_add(content)
	total_quantity.quantity += quantity_to_add

func add_contents(values):
	if values == null:
		return
	if not values is Array:
		values = [values]
	for value in values:
		add_content(value)
	return contents

func add_content(value:AbstractUnit):
	if value == null:
		return
	if value is AbstractQuantity:
		var current_unit = find_content(value.machine_name)
		if current_unit is AbstractQuantity:
			current_unit.quantity += value.quantity
		else:
			contents.append(value)
	else:
		contents.append(value)
	update_quantities()
	return contents

func remove_contents(values):
	if values == null:
		return
	if not values is Array:
		values = [values]
	for value in values:
		remove_content(value)

func remove_content(value:AbstractUnit):
	if value == null:
		return
	if value is AbstractQuantity:
		var content = find_content(value.machine_name)
		if content is AbstractQuantity:
			content.quantity -= value.quantity
			update_quantities()
			return
	var index = contents.find(value)
	if index >= 0:
		contents.remove(index)
		update_quantities()

func find_quantity(machine_name_query:String):
	for quantity in quantities:
		if quantity is AbstractQuantity and quantity.machine_name == machine_name_query:
			return quantity

func find_content(machine_name_query:String):
	for content in contents:
		if content is AbstractUnit and content.machine_name == machine_name_query:
			return content
