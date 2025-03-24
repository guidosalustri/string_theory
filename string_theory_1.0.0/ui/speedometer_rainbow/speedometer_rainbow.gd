@tool
class_name SpeedometerRainbow extends Control

var max_speed := 700.0
@export_range(0.0, 700.0, 1.0) var speed := 0.0

@onready var front: Panel = $Front
@onready var label: Label = $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed_speedometer :float = min((speed * 0.45)/ max_speed,0.45)
	var speed_label :float = min(speed, max_speed)
	front.material.set_shader_parameter("value", speed_speedometer)
	label.text = str(snapped(int(speed_label),25))
