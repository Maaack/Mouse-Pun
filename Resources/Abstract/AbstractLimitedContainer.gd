extends AbstractContainer


class_name AbstractLimitedContainer

const LIMIT_QUANTITY = 'LIMIT_QUANTITY'

export(int,0,16384) var int_limit = 0 setget set_int_limit

var limit_quantity : AbstractQuantity

func set_int_limit(value:int):
	int_limit = value
	if value == null:
		limit_quantity = null
		return
	limit_quantity = AbstractQuantity.new()
	limit_quantity.machine_name = LIMIT_QUANTITY
	limit_quantity.quantity = value

func get_empty_space():
	if limit_quantity == null:
		return
	return (limit_quantity.quantity - total_quantity.quantity)

func add_content(value:AbstractUnit):
	var quantity_to_add = _get_quantity_to_add(value)
	var empty_space = get_empty_space()
	if empty_space != null and empty_space < quantity_to_add:
		return
	return .add_content(value)

