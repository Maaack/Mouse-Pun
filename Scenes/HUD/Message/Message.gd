extends Label


func _ready():
	$AnimationPlayer.play("fade_out")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
