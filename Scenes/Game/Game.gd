extends Node2D


signal send_message


const MUSHROOM_NAME = 'MUSHROOM'
const NUT_NAME = 'NUT'
const CARROT_NAME = 'CARROT'
const APPLE_NAME = 'APPLE'
const BROCCOLI_NAME = 'BROCCOLI'
const PEPPER_NAME = 'PEPPER'


const CAT_NAME = 'Cat'
const FOX_NAME = 'Fox'
const STARVATION_NAME = 'Starvation'

onready var map_node = $Map

var picked_up_objects = 0
var picked_up_mushrooms = 0
var picked_up_nuts = 0
var picked_up_carrots = 0
var picked_up_apples = 0
var picked_up_broccoli = 0

var eaten_objects = 0
var eaten_mushrooms = 0
var eaten_nuts = 0
var eaten_carrots = 0
var eaten_apples = 0
var eaten_broccoli = 0

var damage_from_starvation = 0
var damage_from_cats = 0
var damage_from_fox = 0

func start_game():
	map_node.start_game()
	setup_player_events()
	_send_message("You emerge from your lair, weak, and starving.")
	_send_message("Your vision is blurry, but you see food nearby!")
	_send_message("Move with [WASD] or [Arrow Keys].")

func setup_player_events():
	var player = $Map/Interactives/Interactives/Player
	player.connect("picked_up", self, "_on_Player_picked_up")
	player.connect("ate_food", self, "_on_Player_ate_food")
	player.connect("damaged", self, "_on_Player_damaged")

func get_player():
	return $Map/Interactives/Interactives/Player

func _send_message(message:String):
	emit_signal("send_message", message)

func _on_Player_picked_up(item:AbstractUnit):
	_send_message("You picked up a %s." % [item.readable_name])
	picked_up_objects += 1
	if picked_up_objects == 1:
		_send_message("You should eat that by pressing [E].")
	match(item.machine_name):
		MUSHROOM_NAME:
			picked_up_mushrooms += 1
			if picked_up_mushrooms == 3:
				_send_message("Mushrooms have calories, but only a little fiber.")
		NUT_NAME:
			picked_up_nuts += 1
			if picked_up_nuts == 1:
				_send_message("Nuts have a lot of fiber!")
				_send_message("Switch between multiple items with [0-9].")
		CARROT_NAME:
			picked_up_carrots += 1
			if picked_up_nuts == 1:
				_send_message("Carrots have vitamins for your eyes. Fiber, too!")
				_send_message("Switch between multiple items with [0-9].")
		APPLE_NAME:
			picked_up_apples += 1
			if picked_up_apples == 1:
				_send_message("Shiny, delicious, and healthy, too!")
			if picked_up_apples == 3:
				_send_message("Nice! You found a lot of apples!")
		BROCCOLI_NAME:
			picked_up_broccoli += 1
			if picked_up_broccoli == 1:
				_send_message("Ummm. Yay. Broccoli is VERY healthy.")
			if picked_up_broccoli == 6:
				_send_message("Broccoli IS healthy, but you can relax.")
		PEPPER_NAME:
			_send_message("What?! How did you even?")

func _on_Player_ate_food(item:AbstractUnit):
	_send_message("You ate a %s." % [item.readable_name])
	eaten_objects += 1
	if eaten_objects == 1:
		_send_message("Though relieved of starvation, you should eat more!")
	if eaten_objects == 3:
		_send_message("That's much better! Though your digestion is slow.")
	match(item.machine_name):
		NUT_NAME:
			eaten_nuts += 1
			if eaten_nuts == 1:
				_send_message("Your digestion should improve in time.")
				_send_message("You can rest by pressing [Space].")
		CARROT_NAME:
			eaten_carrots += 1
			if eaten_carrots == 1:
				_send_message("Your vision should clear up after some time.")
				_send_message("You can rest by pressing [Space].")
		APPLE_NAME:
			eaten_apples += 1
			if eaten_apples == 1:
				_send_message("That'll provide a boost to energy and speed! Just wait...")
				_send_message("You can rest by pressing [Space].")
		BROCCOLI_NAME:
			eaten_broccoli += 1
			if eaten_broccoli == 1:
				_send_message("Yuuuummm... You can taste the healthy. Just give it a minute.")
				_send_message("You can rest by pressing [Space].")
			if eaten_broccoli == 6:
				_send_message("You really like broccoli huh?")
		PEPPER_NAME:
			_send_message("Things are getting spicy!")

func _on_Player_damaged(amount:int, from:String = ''):
	if from and from != '':
		_send_message("Took %d damage from %s!" % [amount, from])
		match(from):
			STARVATION_NAME:
				damage_from_starvation += 1
				if damage_from_starvation == 1:
					_send_message("Your stomach aches! The food is close!")
				if damage_from_starvation == 4:
					_send_message("Your body heals a little every move, but you're still hurting.")
				if damage_from_starvation >= 6:
					_send_message("You should eat food immediately!")
			CAT_NAME:
				damage_from_cats += 1
				if damage_from_cats == 1:
					_send_message("Ouch! That cat swiped you from beyond the fence!")
				if damage_from_cats == 2:
					_send_message("Ouch again! That cat is so much faster!")
					_send_message("Eat [E] and rest [Space] to build up calories.")
				if damage_from_cats == 4 and eaten_carrots == 0:
					_send_message("Oof! Eating a carrot will let you see that cat better.")
			FOX_NAME:
				damage_from_fox += 1
				if damage_from_fox == 1:
					_send_message("Ouch! Bad idea to go up against that fox!")
				if damage_from_fox == 2:
					_send_message("Ouch again! What's the plan here?!")
				if damage_from_fox == 4:
					_send_message("How have you survived up until now?")
	else:
		_send_message("Took %d damage!" % [amount])
