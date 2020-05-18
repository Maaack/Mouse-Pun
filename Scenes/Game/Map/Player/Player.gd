extends Node2D


class_name Player

const IDLE_ANIMATION = 'idle'
const WALK_ANIMATION = 'walk'
const RUN_ANIMATION = 'run'
const HURT_ANIMATION = 'hurt'

const UP_VECTOR = Vector2(0,-1)
const DOWN_VECTOR = Vector2(0,1)
const LEFT_VECTOR = Vector2(-1,0)
const RIGHT_VECTOR = Vector2(1,0)

onready var animated_sprite_node = $AnimatedSprite
onready var tween_node = $Tween
onready var grid_node = get_parent()

export(Resource) var body_container

var last_move_direction : Vector2 = Vector2(0, 0)

func _ready():
	animated_sprite_node.play(IDLE_ANIMATION)
	animated_sprite_node.playing = true

func _process(_delta):
	var move_vector = _get_move_vector(Input)
	if move_vector:
		var target_position = grid_node.try_move(self, move_vector)
		if target_position:
			move_to(target_position)
		else:
			bump_against()
	else:
		animated_sprite_node.play(IDLE_ANIMATION)

func _get_move_vector(input):
	if input.is_action_pressed("ui_up"):
		return UP_VECTOR
	elif input.is_action_pressed("ui_down"):
		return DOWN_VECTOR
	elif input.is_action_pressed("ui_left"):
		return LEFT_VECTOR
	elif input.is_action_pressed("ui_right"):
		return RIGHT_VECTOR

func move_to(target_position:Vector2):
	animated_sprite_node.play(WALK_ANIMATION)
	set_process(false)
	var sprite_frames = animated_sprite_node.get_sprite_frames()
	var animate_speed = sprite_frames.get_frame_count(WALK_ANIMATION) / sprite_frames.get_animation_speed(WALK_ANIMATION)
	var start_animation_position = animated_sprite_node.position + (position - target_position)
	var end_animation_position = animated_sprite_node.position
	tween_node.interpolate_property(animated_sprite_node, "position", start_animation_position, end_animation_position, animate_speed)
	position = target_position
	animated_sprite_node.position = start_animation_position
	tween_node.start()
	_wait_to_idle()

func bump_against():
	set_process(false)
	animated_sprite_node.play(HURT_ANIMATION)
	_wait_to_idle()

func _wait_to_idle():
	yield(animated_sprite_node, "animation_finished")
	animated_sprite_node.play(IDLE_ANIMATION)
	set_process(true)
	
