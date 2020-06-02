extends Node2D


class_name PlayerCharacter

const WALK_ANIMATION = 'walk'
const RUN_ANIMATION = 'run'
const HURT_ANIMATION = 'bounce'
const ROLL_ANIMATION = 'roll'
const FACE_UP_ANIMATION = 'face_up'
const FACE_DOWN_ANIMATION = 'face_down'
const FACE_LEFT_ANIMATION = 'face_left'
const FACE_RIGHT_ANIMATION = 'face_right'

const EDIBLE = 'FOOD_ITEM'
const DIGESTABLE = 'DIGESTABLE'
const STOMACH_MAXIMUM = 1000.0

const UP_VECTOR = Vector2(0,-1)
const DOWN_VECTOR = Vector2(0,1)
const LEFT_VECTOR = Vector2(-1,0)
const RIGHT_VECTOR = Vector2(1,0)

const KNOCKBACK_TIME = 0.2

signal picked_up
signal quantity_updated
signal body_updated
signal reveal_tile
signal turn_taken
signal inventory_slot_selected
signal stats_updated
signal speed_updated

onready var animated_sprite_node = $Sprite/AnimatedSprite
onready var sprite_node = $Sprite
onready var tween_node = $Tween
onready var grid_node = get_parent()

export(int) var speed : int = 3
export(float) var base_turn_time : float = 0.75

var health_quantity_resource = preload("res://Resources/Abstract/Quantities/HealthQuantity.tres")
var calories_quantity_resource = preload("res://Resources/Abstract/Quantities/Nutrients/Calories100.tres")
var calories_quantity : AbstractQuantity
var health_quantity : AbstractQuantity
var map_node : Map2D
var body : AbstractContainer
var inventory : AbstractContainer
var stomach : AbstractSampler
var selected_item : AbstractUnit setget set_selected_item
var sprite_node_position : Vector2

var max_health : int = 100
var last_move_direction : Vector2 = Vector2(0, 0)
var stat_manager = preload("res://Scenes/Game/Map/Player/StatManager.gd").new()

func _ready():
	sprite_node_position = sprite_node.position
	body = AbstractContainer.new()
	health_quantity = health_quantity_resource.duplicate()
	calories_quantity = calories_quantity_resource.duplicate()
	max_health = health_quantity.quantity
	body.add_content(health_quantity)
	body.add_content(calories_quantity)
	emit_signal("body_updated", body)
	inventory = AbstractContainer.new()
	stomach = AbstractSampler.new()
	# Sketch
	var temp_node = self
	while (not temp_node is Map2D):
		temp_node = temp_node.get_parent()
	map_node = temp_node

func _process(_delta):
	_process_move_input()

func _input(event):
	_get_action(event)

func _get_action(input):
	if input.is_action_pressed("ui_accept"):
		if is_instance_valid(selected_item):
			return _act_on_inventory_item(selected_item)
	if input.is_action_pressed("ui_select"):
		return wait()
	if input.is_action_pressed("ui_slot_1"):
		emit_signal("inventory_slot_selected", 1)
		

func _act_on_inventory_item(item:AbstractUnit):
	if item == null:
		return
	match item.taxonomy:
		EDIBLE:
			var eaten = _eat(item)
			if eaten:
				remove_from_inventory(eaten)

func _eat(item:AbstractContainer):
	if item == null:
		return
	if stomach.total_quantity and stomach.total_quantity.quantity > STOMACH_MAXIMUM:
		print("You are full! " , stomach.total_quantity  , " : " , stomach.total_quantity.quantity > STOMACH_MAXIMUM)
		return
	for content in item.contents:
		if content is AbstractUnit:
			match content.taxonomy:
				EDIBLE:
					_eat(content)
					item.remove_content(content)
				DIGESTABLE:
					stomach.add_content(content)
	return item


func _process_move_input():
	var move_vector = _get_move_vector(Input)
	if move_vector:
		_face_direction(move_vector)
		var target_position = grid_node.try_move(self, move_vector)
		if target_position:
			move_to(target_position)
		else:
			bump_against()
		end_turn()

func _get_move_vector(input):
	if input.is_action_pressed("ui_up"):
		return UP_VECTOR
	elif input.is_action_pressed("ui_down"):
		return DOWN_VECTOR
	elif input.is_action_pressed("ui_left"):
		return LEFT_VECTOR
	elif input.is_action_pressed("ui_right"):
		return RIGHT_VECTOR

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

func move_to(target_position:Vector2):
	var speed = get_speed()
	burn_calories(speed)
	set_process(false)
	set_process_input(false)
	var animation_length = $AnimationPlayer.get_animation(WALK_ANIMATION).length
	$AnimationPlayer.playback_speed = animation_length / get_turn_time()
	var start_animation_position = sprite_node.position + (position - target_position)
	var end_animation_position = sprite_node_position
	tween_node.interpolate_property(sprite_node, "position", start_animation_position, end_animation_position, get_turn_time())
	position = target_position
	sprite_node.position = start_animation_position
	tween_node.start()
	$AnimationPlayer.play(WALK_ANIMATION)
	$WalkingAudioStream.play()

func roll_to(target_position:Vector2):
	set_process(false)
	set_process_input(false)
	var start_animation_position = sprite_node.position + (position - target_position)
	var end_animation_position = sprite_node_position
	var animate_speed = KNOCKBACK_TIME
	tween_node.interpolate_property(sprite_node, "position", start_animation_position, end_animation_position, animate_speed)
	position = target_position
	sprite_node.position = start_animation_position
	tween_node.start()
	animated_sprite_node.play(ROLL_ANIMATION)
	$SqueakAudioStream.play()

func knock_back(direction:Vector2):
	var target_position = grid_node.try_move(self, direction)
	if target_position:
		roll_to(target_position)
	else:
		bump_against()

func bump_against():
	$AnimationPlayer.play(HURT_ANIMATION)

func start_turn():
	var result = wait_to_idle()
	if result is GDScriptFunctionState:
		yield(result, "completed")
	_digest_stomach_contents()
	calculate_stats()
	_heal_self()
	_pickup_from_position(position)
	_reveal_neighboring_tiles()
	set_process(true)
	set_process_input(true)

func wait_to_idle():
	if animated_sprite_node.is_playing():
		yield(animated_sprite_node, "animation_finished")
	if tween_node.is_active():
		yield(tween_node, "tween_all_completed")
		sprite_node.position = sprite_node_position
	return

func wait():
	end_turn()

func update_health(value:int):
	if value > 0:
		var max_healing = max_health - health_quantity.quantity
		value = min(value, max_healing)
	elif value < 0 and health_quantity.quantity >= 0:
		value = max(value, -health_quantity.quantity)
	if value == 0:
		return
	return health_quantity.add_quantity(value)

func heal(value:int):
	return update_health(value)

func damage(value:int):
	return update_health(-value)

func _heal_self():
	var healing = int(stat_manager.healing_stat.quantity)
	var quantity = body.find_content(stat_manager.HEALING_VITAMIN)
	if is_instance_valid(quantity):
		var extra_healing = healing - stat_manager.BASE_HEALING
		quantity.quantity -= extra_healing
	heal(healing)

func end_turn():
	set_process(false)
	set_process_input(false)
	emit_signal("turn_taken", self)

func _pickup_from_position(vector:Vector2):
	var container = map_node.pickup_from_position(vector)
	if container is AbstractContainer:
		for content in container.contents:
			emit_signal("picked_up", content)
			print("picked_up ", content)
			if content is AbstractUnit:
				add_to_inventory(content)

func add_to_inventory(content:AbstractUnit):
	if content == null:
		return
	inventory.add_content(content)
	if not is_instance_valid(selected_item):
		selected_item = content
	var quantity = inventory.find_quantity(content.machine_name)
	emit_signal("quantity_updated", quantity)

func remove_from_inventory(content:AbstractUnit):
	if content == null:
		return
	inventory.remove_content(content)
	if selected_item == content:
		selected_item = inventory.find_content(content.machine_name)
	var quantity = inventory.find_quantity(content.machine_name)
	emit_signal("quantity_updated", quantity)

func set_selected_item(value:AbstractUnit):
	if inventory.contents.has(value):
		selected_item = value
	
func burn_calories(value:int):
	if calories_quantity.quantity > 0:
		value = min(value, calories_quantity.quantity)
		add_calories(-value)

func add_calories(value:int):
	if calories_quantity == null:
		return
	if calories_quantity is AbstractQuantity:
		calories_quantity.quantity += value

func _digest_stomach_contents():
	var metabolism : int = int(stat_manager.metabolism_stat.quantity)
	var quantity = body.find_content(stat_manager.METABOLISM_VITAMIN)
	if is_instance_valid(quantity):
		var extra_metabolism = float(metabolism - stat_manager.BASE_METABOLISM)
		quantity.quantity -= floor(extra_metabolism / stat_manager.BASE_METABOLISM)
	stomach.update_quantities()
	print("Stomach ", stomach)
	var sample : AbstractContainer = stomach.sample(metabolism)
	if sample == null:
		print("Hungry")
		damage(3)
		return
	body.add_contents(sample.contents)
	emit_signal("body_updated", body)

func _reveal_neighboring_tiles():
	var vision_range = _get_vision_range()
	for x in range(-vision_range, vision_range + 1):
		for y in range(-vision_range, vision_range + 1):
			var tile_position = grid_node.world_to_map(position)
			var offset_tile_position : Vector2 = tile_position + Vector2(x,y)
			emit_signal("reveal_tile", offset_tile_position)

func _get_vision_range():
	return int(stat_manager.vision_stat.quantity)

func get_speed():
	return int(stat_manager.speed_stat.quantity)

func calculate_stats():
	stat_manager.update_player_stats(body)
	if stat_manager.speed_stat_diff != 0:
		emit_signal("speed_updated")
	if stat_manager.is_updated():
		emit_signal("stats_updated", stat_manager.container)

func get_turn_time():
	return base_turn_time
