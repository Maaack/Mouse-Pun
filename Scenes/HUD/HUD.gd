extends Control


onready var body_information_node = $MarginContainer/Control/TopLeft/BodyInformation

func show_containers(container:AbstractContainer):
	if container == null:
		return
	for inner_container in container.contents:
		body_information_node.show_container(inner_container)
