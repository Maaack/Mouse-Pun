extends AbstractUnit


class_name AbstractContainer

export(Array, Resource) var contents : Array setget set_contents

var quantities : Array = []

func _to_string():
	var to_string = "%s: [" % machine_name
	for content in contents:
		to_string += str(content) + ","
	return to_string + "]"

func set_contents(value:Array):
	if value == null:
		return
	contents = _return_valid_array(value)
	
func _return_valid_array(array:Array):
	var final_array : Array = []
	for unit in array:
		if unit is AbstractUnit:
			final_array.append(unit.duplicate())
	return final_array

func _reset_quantities():
	for quantity in quantities:
		if quantity is AbstractQuantity:
			quantity.quantity = 0

func _update_quantities():
	_reset_quantities()
	for content in contents:
		if content is AbstractUnit:
			var quantity_to_add = 1
			if content is AbstractQuantity:
				quantity_to_add = content.quantity
			var quantity : AbstractQuantity
			quantity = find_quantity(content.machine_name)
			if quantity:
				quantity.quantity += quantity_to_add
			else:
				quantity = AbstractQuantity.new()
				quantity.copy_from(content)
				quantity.quantity = quantity_to_add
				quantities.append(quantity)

func add_content(value:AbstractUnit):
	if value == null:
		return
	contents.append(value)
	_update_quantities()
	return contents

func remove_content(value:AbstractUnit):
	if value == null:
		return
	var index = contents.find(value)
	if index >= 0:
		contents.remove(index)
		_update_quantities()

func find_quantity(machine_name_query:String):
	for quantity in quantities:
		if quantity is AbstractQuantity and quantity.machine_name == machine_name_query:
			return quantity

func find_content(machine_name_query:String):
	for content in contents:
		if content is AbstractUnit and content.machine_name == machine_name_query:
			return content
