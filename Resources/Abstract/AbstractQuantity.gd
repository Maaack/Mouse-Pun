extends AbstractUnit


class_name AbstractQuantity

export(float) var quantity = 1.0 setget set_quantity

func _to_string():
	return "%s, %f" % [._to_string(), quantity]

func set_quantity(value:float):
	quantity = value
	_discrete_unit_check()

func _discrete_unit_check():
	if quantity != null && numerical_unit == NumericalUnitSetting.DISCRETE:
		var lt_zero = quantity < 0
		quantity = floor(abs(quantity))
		if lt_zero:
			quantity *= -1

func add_quantity(value:float):
	if value == null or value == 0.0:
		return
	set_quantity(quantity + value)

func split(value:float) -> AbstractQuantity:
	if quantity <= 0 or value <= 0:
		print("Error: Splitting only supports positive quantities.")
	var split_quantity = duplicate()
	if value == null or value == 0.0:
		split_quantity.quantity = 0
		return split_quantity
	value = min(value, quantity)
	add_quantity(-value)
	split_quantity.quantity = value
	return split_quantity

func copy_from(value:AbstractUnit):
	if value == null:
		return
	if value.has_method('set_quantity'):
		quantity = value.quantity
	.copy_from(value)

func add(value, conserve_quantities:bool=true):
	if not is_instance_valid(value):
		return
	if not value.has_method('set_quantity'):
		print("Error: Adding incompatible types ", str(value), " and ", str(self))
		return
	if value.machine_name != machine_name:
		print("Error: Adding incompatible quantities ", str(value), " and ", str(self))
		return
	add_quantity(value.quantity)
	if conserve_quantities:
		value.quantity = 0
