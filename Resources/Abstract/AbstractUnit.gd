extends Resource


class_name AbstractUnit

export(String) var machine_name
export(String) var readable_name
export(Texture) var icon

enum NumericalUnitSetting{ DISCRETE, CONTINUOUS }
export(NumericalUnitSetting) var numerical_unit = NumericalUnitSetting.DISCRETE

func _to_string():
	return "%s (%d)" % [machine_name, get_instance_id()]
