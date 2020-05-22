tool
extends Node2D


class_name Item

signal picked_up

export(Resource) var unit setget set_unit

func set_unit(value:AbstractUnit):
	unit = value.duplicate()
	if is_instance_valid(unit):
		$Sprite.texture = unit.icon

func pickup():
	if is_instance_valid(self):
		queue_free()
		emit_signal("picked_up", unit)
		return unit
