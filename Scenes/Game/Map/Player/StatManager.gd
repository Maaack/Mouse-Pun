
const CALORIES = 'CALORIES'
const METABOLISM_VITAMIN = 'METABOLISM_VITAMIN'
const EYESIGHT_VITAMIN = 'EYESIGHT_VITAMIN'
const VISION_VITAMIN = 'VISION_VITAMIN'
const HEALING_VITAMIN = 'HEALING_VITAMIN'
const HEALTH_QUANTITY = 'HEALTH_QUANTITY'

const BASE_METABOLISM = 5
const BASE_HEALING = 1
const BASE_VISION = 1
const BASE_SPEED = 2
const VITAMIN_STEP_SIZE = 100
const CALORIES_STEP_SIZE = 200
const STAT_INCREASE_OFFSET = 20

var health = preload("res://Resources/Abstract/Quantities/HealthQuantity.tres").duplicate()
var metabolism_stat = preload("res://Resources/Abstract/Quantities/MetabolismStat.tres").duplicate()
var healing_stat = preload("res://Resources/Abstract/Quantities/HealingStat.tres").duplicate()
var speed_stat = preload("res://Resources/Abstract/Quantities/SpeedStat.tres").duplicate()
var vision_stat = preload("res://Resources/Abstract/Quantities/VisionStat.tres").duplicate()

var health_diff : int
var healing_stat_diff : int
var speed_stat_diff : int
var vision_stat_diff : int
var metabolism_stat_diff : int
var container : AbstractContainer

func _init():
	container = AbstractContainer.new()
	container.add_contents([health, metabolism_stat, healing_stat, speed_stat, vision_stat])
	
func update_player_stats(body:AbstractContainer):
	health_diff = update_health(body)
	healing_stat_diff = update_healing_stat(body)
	metabolism_stat_diff = update_metabolism_stat(body)
	speed_stat_diff = update_speed_stat(body)
	vision_stat_diff = update_vision_stat(body)

func is_updated() -> bool:
	return health_diff != 0 or healing_stat_diff != 0 or speed_stat_diff != 0 or vision_stat_diff != 0

func update_health(body: AbstractContainer):
	var diff : int = 0
	var quantity : AbstractQuantity 
	quantity = body.find_content(HEALTH_QUANTITY)
	if is_instance_valid(quantity) and quantity.quantity != health.quantity:
		diff = quantity.quantity - health.quantity
		health.quantity = quantity.quantity
	return diff

func _update_stat(body: AbstractContainer, stat:AbstractQuantity, machine_name:String, base_stat:int, step_size:int) -> int:
	var diff : int = 0
	var quantity : AbstractQuantity 
	quantity = body.find_content(machine_name)
	var vitamin_quantity : float = 0.0
	if is_instance_valid(quantity):
		vitamin_quantity = quantity.quantity
	var offset_boost_stat : int = ceil(max(0, vitamin_quantity - STAT_INCREASE_OFFSET) / step_size)
	var boost_stat : int = ceil(vitamin_quantity / step_size)
	if stat.quantity > (base_stat + boost_stat):
		diff = (base_stat + boost_stat) - stat.quantity
	if stat.quantity < (base_stat + offset_boost_stat):
		diff = (base_stat + offset_boost_stat) - stat.quantity
	stat.add_quantity(diff)
	return diff
	
func update_metabolism_stat(body:AbstractContainer):
	var diff : int = _update_stat(body, metabolism_stat, METABOLISM_VITAMIN, BASE_METABOLISM, VITAMIN_STEP_SIZE)
	if diff > 0:
		print("Your appetite grows!")
	elif diff < 0:
		print("Your appetite shrinks!")
	return diff

func update_healing_stat(body:AbstractContainer):
	var diff : int = _update_stat(body, healing_stat, HEALING_VITAMIN, BASE_HEALING, VITAMIN_STEP_SIZE)
	if diff > 0:
		print("Your body feels resilient!")
	elif diff < 0:
		print("Your body feels vulnerable!")
	return diff

func update_speed_stat(body:AbstractContainer):
	var diff : int = _update_stat(body, speed_stat, CALORIES, BASE_SPEED, CALORIES_STEP_SIZE)
	if diff > 0:
		print("You feel faster!")
	elif diff < 0:
		print("You feel slower!")
	return diff

func update_vision_stat(body:AbstractContainer):
	var diff : int = _update_stat(body, vision_stat, EYESIGHT_VITAMIN, BASE_VISION, VITAMIN_STEP_SIZE)
	if diff > 0:
		print("Your vision has cleared!")
	elif diff < 0:
		print("Your vision has gotten foggier!")
	return diff
