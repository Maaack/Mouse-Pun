extends Node2D


class_name PlayerCharacter

const IDLE_ANIMATION = 'idle'
const WALK_ANIMATION = 'walk'
const RUN_ANIMATION = 'run'
const HURT_ANIMATION = 'hurt'

const EDIBLE = 'FOOD_ITEM'
const DIGESTABLE = 'DIGESTABLE'

const EYESIGHT_VITAMIN = 'EYESIGHT_VITAMIN'

const UP_VECTOR = Vector2(0,-1)
const DOWN_VECTOR = Vector2(0,1)
const LEFT_VECTOR = Vector2(-1,0)
const RIGHT_VECTOR = Vector2(1,0)

const CALORIES_PER_MOVE = 2
const DIGESTED_UNITS_PER_TURN = 5
const EYESIGHT_VITAMIN_STEP = 100
const KNOCKBACK_TIME = 0.2

signal picked_up
signal quantity_updated
signal body_updated
signal reveal_tile
signal turn_taken
signal inventory_slot_selected

onready var animated_sprite_node = $AnimatedSprite
onready var tween_node = $Tween
onready var grid_node = get_parent()

var health_quantity_resource = preload("res://Resources/Abstract/Quantities/HealthQuantity.tres")
var calories_quantity_resource = preload("res://Resources/Abstract/Quantities/Nutrients/Calories100.tres")
var calories_quantity : AbstractQuantity
var health_quantity : AbstractQuantity
var map_node : Map2D
var body : AbstractContainer
var inventory : AbstractContainer
var stomach : AbstractSampler
var selected_item : AbstractUnit setget set_selected_item

var max_health : int = 100
var last_move_direction : Vector2 = Vector2(0, 0)

func _ready():
	animated_sprite_node.play(IDLE_ANIMATION)
	animated_sprite_node.playing = true
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
			_eat(item, inventory)
			remove_from_inventory(item)

func _eat(item:AbstractContainer, from_container:AbstractContainer):
	if item == null:
		return
	var for_removal : Array = []
	for content in item.contents:
		if content is AbstractUnit:
			print("content : ", content)
			match content.taxonomy:
				EDIBLE:
					_eat(content, item)
					from_container.remove_content(item)
				DIGESTABLE:
					stomach.add_content(content)
					for_removal.append(content)
					print("Stomach ", stomach)
	for content in for_removal:
		from_container.remove_content(content)

func _process_move_input():
	var move_vector = _get_move_vector(Input)
	if move_vector:
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

func move_to(target_position:Vector2):
	burn_calories(CALORIES_PER_MOVE)
	animated_sprite_node.play(WALK_ANIMATION)
	set_process(false)
	set_process_input(false)
	var sprite_frames = animated_sprite_node.get_sprite_frames()
	var animate_speed = sprite_frames.get_frame_count(WALK_ANIMATION) / sprite_frames.get_animation_speed(WALK_ANIMATION)
	var start_animation_position = animated_sprite_node.position + (position - target_position)
	var end_animation_position = animated_sprite_node.position
	tween_node.interpolate_property(animated_sprite_node, "position", start_animation_position, end_animation_position, animate_speed)
	position = target_position
	animated_sprite_node.position = start_animation_position
	tween_node.start()

func roll_to(target_position:Vector2):
	set_process(false)
	set_process_input(false)
	var start_animation_position = animated_sprite_node.position + (position - target_position)
	var end_animation_position = animated_sprite_node.position
	var animate_speed = KNOCKBACK_TIME
	tween_node.interpolate_property(animated_sprite_node, "position", start_animation_position, end_animation_position, animate_speed)
	position = target_position
	animated_sprite_node.position = start_animation_position
	tween_node.start()

func knock_back(direction:Vector2):
	var target_position = grid_node.try_move(self, direction)
	if target_position:
		roll_to(target_position)
	else:
		bump_against()

func bump_against():
	animated_sprite_node.play(HURT_ANIMATION)

func start_turn():
	var result = _wait_to_idle()
	if result is GDScriptFunctionState:
		yield(result, "completed")
	_pickup_from_position(position)
	_digest_stomach_contents()
	_reveal_neighboring_tiles()
	set_process(true)
	set_process_input(true)

func _wait_to_idle():
	if animated_sprite_node.is_playing():
		yield(animated_sprite_node,"animation_finished")
	if tween_node.is_active():
		yield(tween_node, "tween_all_completed")
	animated_sprite_node.play(IDLE_ANIMATION)
	return

func wait():
	end_turn()

func update_health(value:int):
	if value > 0 and health_quantity.quantity < max_health:
		var max_healing = max_health - health_quantity.quantity
		value = min(value, max_healing)
	elif value < 0 and health_quantity.quantity > 0:
		value = max(value, -health_quantity.quantity)
	if value == 0:
		return
	return health_quantity.add_quantity(value)

func heal(value:int):
	return update_health(value)

func damage(value:int):
	return update_health(-value)

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
	add_calories(-value)

func add_calories(value:int):
	if calories_quantity == null:
		return
	if calories_quantity is AbstractQuantity:
		calories_quantity.quantity += value

func _digest_stomach_contents():
	var sample : AbstractContainer = stomach.sample(DIGESTED_UNITS_PER_TURN)
	if sample == null:
		print("Hungry")
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
	var vision_range : int = 1
	var quantity : AbstractQuantity = body.find_content(EYESIGHT_VITAMIN)
	if is_instance_valid(quantity):
		var spendable : int = ceil(quantity.quantity / EYESIGHT_VITAMIN_STEP)
		if spendable > quantity.quantity:
			spendable = quantity.quantity
		quantity.quantity -= spendable
		vision_range += spendable
	return vision_range
