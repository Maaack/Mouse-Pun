extends VBoxContainer


var progress_bar_scene = preload("res://Scenes/HUD/ProgressBar/ProgressBar.tscn")

func show_container(container:AbstractContainer):
	var progress_bar = progress_bar_scene.instance()
	add_child(progress_bar)
	progress_bar.set_container(container)
