extends VBoxContainer


onready var message_scene = preload("res://Scenes/HUD/Message/Message.tscn")

func add_message(message:String):
	if message == null or message == "":
		return
	var message_instance = message_scene.instance()
	message_instance.text = message
	add_child(message_instance)
	return message_instance
