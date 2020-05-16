extends Control


onready var counter_node = $MarginContainer/HBoxContainer/Counter
onready var progress_node = $MarginContainer/HBoxContainer/TextureProgress

var texture_desired_size = Vector2(24.0, 24.0)
var container : AbstractContainer

func _process(delta):
	_update_progress_bar()

func set_container(value:AbstractContainer):
	if value == null:
		return
	container = value
	_set_counter()

func _set_counter():
	if container == null:
		return
	counter_node.quantity = container.contents.front()

func _update_progress_bar():
	if container == null:
		return
	if container.has_quantity_limit():
		progress_node.max_value = container.quantity_limit
	var content = container.contents.front()
	if content is AbstractQuantity:
		var progress = content.quantity
		if progress != null:
			set_progress_bar(round(progress))

func set_progress_bar(value):
	progress_node.value = value
