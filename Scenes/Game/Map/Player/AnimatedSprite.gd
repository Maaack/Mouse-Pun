extends AnimatedSprite


func _on_AnimatedSprite_animation_finished():
	# This is necessary
	if not frames.get_animation_loop(animation):
		stop()
