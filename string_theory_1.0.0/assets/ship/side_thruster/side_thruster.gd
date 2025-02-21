# See the main thrusters script for some explanations of how the code works.
# This script uses very similar code to the main thrusters script, but it's simpler.
extends Sprite2D

@export var alpha_curve: Curve
@export_range(0.0, 1.0, 0.1) var power: = 1.0:
	set(value):
		power = value
		scale = _initial_scale * power
		if alpha_curve != null:
			modulate.a = alpha_curve.sample(power)
@export var emit := true

@onready var _initial_scale := scale


func _process(delta: float) -> void:	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0.0:
		power = lerp(power, 1.0, 10.0 * delta)
	else:
		power = max(0.0, power - 2.0 * delta)
	
	if not emit:
		power = 0

	power = max(0.0, power - 2.0 * delta)
