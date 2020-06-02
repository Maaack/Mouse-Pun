extends Control


onready var body_information_node = $MarginContainer/Control/TopLeft/BodyInformation
onready var quickslots_node = $MarginContainer/Control/CenterBottom/Quickslots
onready var messages_node = $MarginContainer/Control/TopRight/Messages

func update_body_container(container:AbstractContainer):
	if container == null:
		return
	for content in container.contents:
		if content is AbstractContainer:
			body_information_node.add_container(content)
		elif content is AbstractQuantity:
			body_information_node.add_quantity(content)

func add_container_to_body_information(container:AbstractContainer):
	body_information_node.add_container(container)
	
func add_quantity_to_body_information(quantity:AbstractQuantity):
	body_information_node.add_quantity(quantity)

func update_quickslots(slots:Array):
	quickslots_node.update_quickslots(slots)

func update_selected(index:int):
	quickslots_node.update_selected(index)

func add_message(message:String):
	messages_node.add_message(message)
