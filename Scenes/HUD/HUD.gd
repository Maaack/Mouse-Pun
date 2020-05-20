extends Control


onready var body_information_node = $MarginContainer/Control/TopLeft/BodyInformation
onready var quickslots_node = $MarginContainer/Control/CenterBottom/Quickslots

func show_containers(container:AbstractContainer):
	if container == null:
		return
	for inner_container in container.contents:
		body_information_node.show_container(inner_container)

func add_quantity_to_quickslot(quantity:AbstractQuantity):
	quickslots_node.add_quantity(quantity)
