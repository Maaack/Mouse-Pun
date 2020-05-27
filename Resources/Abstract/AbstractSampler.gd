extends AbstractLimitedContainer


class_name AbstractSampler

export(float,0,10) var sample_modifier = 0.5

var sampleable_quantities : Array = []

func sample(value:int):
	var sample : AbstractContainer = AbstractContainer.new()
	_update_sampleable_quantities()
	for i in range(value):
		var next_quantity = _get_next_largest_sample_quantity()
		if next_quantity == null:
			break
		var content = find_content(next_quantity.machine_name)
		if content and content is AbstractQuantity:
			var next_unit = _get_unit_of_content(content)
			if next_unit.quantity < 1:
				continue
			sample.add_content(next_unit)
			_sub_unit_from_content(next_unit)
			next_quantity.quantity *= sample_modifier
	if sample.contents.size() == 0:
		return
	return sample

func _sub_unit_from_content(value:AbstractUnit):
	if value == null:
		return
	var content = find_content(value.machine_name)
	if value is AbstractQuantity and content is AbstractQuantity:
		content.quantity -= value.quantity
		return content
	remove_content(content)

func _get_unit_of_content(content:AbstractUnit):
	var content_unit : AbstractUnit = content.duplicate()
	if content_unit is AbstractQuantity and content_unit.quantity >= 1.0:
		content_unit.quantity = 1.0
	return content_unit

func _update_sampleable_quantities():
	sampleable_quantities = []
	_update_quantities()
	for quantity in quantities:
		if quantity is AbstractQuantity:
			sampleable_quantities.append(quantity.duplicate())

func _get_next_largest_sample_quantity():
	var largest_quantity : AbstractQuantity = null
	for quantity in sampleable_quantities:
		if quantity is AbstractQuantity:
			if largest_quantity == null:
				largest_quantity = quantity
			elif quantity.quantity > largest_quantity.quantity:
				largest_quantity = quantity
	return largest_quantity
			
