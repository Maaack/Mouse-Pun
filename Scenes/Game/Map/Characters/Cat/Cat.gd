extends Character


export(int) var attack_damage = 10
export(int) var speed = 6

func start_turn():
	var result = wait_to_idle()
	if result is GDScriptFunctionState:
		yield(result, "completed")
	var attacked = try_to_attack()
	if attacked is GDScriptFunctionState:
		attacked = yield(attacked, "completed")
	if not attacked:
		try_to_move()
	end_turn()

func try_to_attack():
	var attacked : bool = false
	var attack_direction = move_direction.rotated(-PI)
	for i in range(3):
		attack_direction = attack_direction.rotated(PI/2)
		var target_node = grid_node.try_to_interact(self, attack_direction)
		if target_node:
			if target_node.has_method("wait_to_idle"):
				var result = target_node.wait_to_idle()
				if result is GDScriptFunctionState:
					yield(result, "completed")
			attack(target_node)
			knock_back(target_node, attack_direction)
			attacked = true
	return attacked

func attack(character:Node2D):
	if character.has_method("damage"):
		character.damage(attack_damage)

func knock_back(character:Node2D, direction:Vector2):
	if character.has_method("knock_back"):
		character.knock_back(direction)

func get_speed():
	return speed
