extends VBoxContainer


var progress_bar_scene = preload("res://Scenes/HUD/ProgressBar/ProgressBar.tscn")
var counter_scene = preload("res://Scenes/HUD/Counter/Counter.tscn")

func show_container(container:AbstractContainer):
	var instance
	if container.has_quantity_limit():
		instance = progress_bar_scene.instance()
	else:
		instance = counter_scene.instance()
	add_child(instance)
	instance.set_container(container)
