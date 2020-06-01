extends Node2D


class_name Character

const DEAD_ANIMATION = 'dead'
const FACE_UP_ANIMATION = 'face_up'
const FACE_DOWN_ANIMATION = 'face_down'
const FACE_LEFT_ANIMATION = 'face_left'
const FACE_RIGHT_ANIMATION = 'face_right'

const UP_VECTOR = Vector2(0,-1)
const DOWN_VECTOR = Vector2(0,1)
const LEFT_VECTOR = Vector2(-1,0)
const RIGHT_VECTOR = Vector2(1,0)

signal turn_taken

onready var animated_sprite_node = $AnimatedSprite
onready var tween_node = $Tween
onready var grid_node = get_parent()

export(Vector2) var move_direction : Vector2 = UP_VECTOR

var turn_time : float = 1.0 setget set_turn_time

func set_turn_time(value:float):
	turn_time = value

func start_turn():
	var result = wait_to_idle()
	if result is GDScriptFunctionState:
		yield(result, "completed")
	try_to_move()
	end_turn()

func end_turn():
	emit_signal("turn_taken", self)

func try_to_move():
	_face_direction(move_direction)
	var target_position = grid_node.try_move(self, move_direction)
	if target_position:
		move_to(target_position)
	else:
		move_direction = -move_direction

func move_to(target_position:Vector2):
	var start_animation_position = animated_sprite_node.position + (position - target_position)
	var end_animation_position = animated_sprite_node.position
	tween_node.interpolate_property(animated_sprite_node, "position", start_animation_position, end_animation_position, turn_time)
	position = target_position
	animated_sprite_node.position = start_animation_position
	tween_node.start()

func wait_to_idle():
	if tween_node.is_active():
		yield(tween_node, "tween_all_completed")
	return

func _face_direction(direction:Vector2):
	match(direction):
		UP_VECTOR:
			animated_sprite_node.animation = FACE_UP_ANIMATION
		DOWN_VECTOR:
			animated_sprite_node.animation = FACE_DOWN_ANIMATION
		LEFT_VECTOR:
			animated_sprite_node.animation = FACE_LEFT_ANIMATION
		RIGHT_VECTOR:
			animated_sprite_node.animation = FACE_RIGHT_ANIMATION
