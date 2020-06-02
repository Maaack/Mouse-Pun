extends Node2D


signal restart_game

func _on_Button_button_down():
	emit_signal("restart_game")
