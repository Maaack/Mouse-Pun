extends VBoxContainer


var progress_bar_scene = preload("res://Scenes/HUD/ProgressBar/ProgressBar.tscn")
var counter_scene = preload("res://Scenes/HUD/Counter/Counter.tscn")

func show_container(container:AbstractContainer):
	var instance = counter_scene.instance()
	add_child(instance)
	instance.container = container
