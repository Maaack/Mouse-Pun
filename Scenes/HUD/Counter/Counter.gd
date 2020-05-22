extends Control


onready var label_node = $MarginContainer/HBoxContainer/Label
onready var texture_node = $MarginContainer/HBoxContainer/Texture

var quantity : AbstractQuantity setget set_quantity
var container : AbstractContainer setget set_container

func _process(delta):
	_update_counter()

func set_quantity(value:AbstractQuantity):
	if value == null:
		return
	quantity = value
	_update_icon()
	_update_counter()

func set_container(value:AbstractContainer):
	if value == null:
		return
	container = value
	quantity = value.contents.front()
	_update_icon()
	_update_counter()
	

func _update_icon():
	if quantity == null:
		return
	if quantity.icon == null:
		print(quantity, " doesn't have an icon!")
		return
	texture_node.texture = quantity.icon
	var get_size = texture_node.texture.get_size()
	var texture_desired_size = Vector2(1,1) * label_node.get_rect().size.y
	var scale_mod = texture_desired_size/get_size
	texture_node.rect_scale = scale_mod

func _update_counter():
	if quantity == null:
		return
	var value = quantity.quantity
	if quantity.numerical_unit == quantity.NumericalUnitSetting.DISCRETE:
		value = str(round(value))
	else:
		var value_str = "%.*f"
		var precision = _get_continuous_precision(value)
		value = value_str % [precision, value]
#	if container != null and container.quantity_limit >= 0:
#		value = value + (" / %d" % container.quantity_limit)
	_set_counter(value)

func _set_counter(value:String):
	label_node.set_text(value)

func _get_continuous_precision(value:float):
	var precision = 0
	var abs_value = abs(value)
	if abs_value != 0:
		if abs_value < 100:
			precision += 1
		if abs_value < 10:
			precision += 1
		if abs_value < 1:
			precision += 1
	return precision
