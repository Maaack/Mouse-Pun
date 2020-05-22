extends Resource


class_name AbstractUnit

export(String) var machine_name
export(String) var readable_name
export(Texture) var icon
export(String) var taxonomy

enum NumericalUnitSetting{ DISCRETE, CONTINUOUS }
export(NumericalUnitSetting) var numerical_unit = NumericalUnitSetting.DISCRETE

func _to_string():
	return "%s (%d)" % [machine_name, get_instance_id()]

func copy_from(value:AbstractUnit):
	if value == null:
		return
	machine_name = value.machine_name
	readable_name = value.readable_name
	icon = value.icon
	taxonomy = value.taxonomy
