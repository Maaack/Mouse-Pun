extends Resource


class_name OldAbstractContent

export(Array, Resource) var units setget set_units

var quantities = []

func set_units(array:Array):
	units = _return_valid_array(array)
	_update_quantities()

func _return_valid_array(array:Array):
	var final_array : Array = []
	for unit in array:
		if unit is AbstractUnit:
			final_array.append(unit)
	return final_array

func _reset_quantities():
	for quantity in quantities:
		if quantity is AbstractQuantity:
			quantity.quantity = 0

func _update_quantities():
	_reset_quantities()
	for unit in units:
		if unit is AbstractUnit:
			var quantity : AbstractQuantity
			quantity = find_quantity(unit.machine_name)
			if quantity == null:
				quantity = AbstractQuantity.new()
				quantity.copy_from(unit)
				quantities.append(quantity)
			quantity.quantity += 1

func add_unit(unit:AbstractUnit):
	if unit == null:
		return
	units.append(unit)
	_update_quantities()

func remove_unit(unit:AbstractUnit):
	if unit == null:
		return
	var index : int = units.find(unit)
	if index >= 0:
		units.remove(index)

func find_quantity(machine_name_query:String):
	for quantity in quantities:
		if quantity is AbstractQuantity and quantity.machine_name == machine_name_query:
			return quantity

func find_unit(machine_name_query:String):
	for unit in units:
		if unit is AbstractUnit and unit.machine_name == machine_name_query:
			return unit
