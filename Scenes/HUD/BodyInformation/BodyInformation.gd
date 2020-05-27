extends VBoxContainer


var progress_bar_scene = preload("res://Scenes/HUD/ProgressBar/ProgressBar.tscn")
var counter_scene = preload("res://Scenes/HUD/Counter/Counter.tscn")

var body_array = []

func add_quantity(quantity:AbstractQuantity):
	if quantity == null:
		return
	if find(quantity.machine_name) != null:
		return
	body_array.append(quantity)
	var counter = add_counter()
	counter.quantity = quantity

func add_container(container:AbstractContainer):
	if container == null:
		return
	if find(container.machine_name) != null:
		return
	body_array.append(container)
	var counter = add_counter()
	counter.container = container

func add_counter():
	var instance = counter_scene.instance()
	add_child(instance)
	return instance

func find(machine_name_query:String):
	for body_unit in body_array:
		if body_unit is AbstractUnit:
			if body_unit.machine_name == machine_name_query:
				return body_unit

