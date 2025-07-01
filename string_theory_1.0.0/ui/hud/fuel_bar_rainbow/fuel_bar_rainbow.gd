@tool
class_name FuelBarRainbow extends Control

@export_range(0.0, 5.0) var fuel := 2.5
var max_fuel = 5.0

@onready var panel_front: Panel = $PanelFront
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	panel_front.material.set_shader_parameter("value", fuel / max_fuel)
