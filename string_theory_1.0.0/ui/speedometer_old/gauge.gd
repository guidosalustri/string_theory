@tool
class_name GaugeOld extends Control

@onready var main_gauge: TextureRect = $MainGauge
@onready var secondary_gauge: TextureRect = $SecondaryGauge
@onready var main_line: Node2D = $MainLine
@onready var secondary_line: Node2D = $SecondaryLine
@onready var main_gauge_label: Label = $MainGaugeLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const MAIN_ZERO_STATE := 580.0
const MAIN_FULL_STATE := 320.0

const MAIN_LINE_ZERO := 138.0
const MAIN_LINE_FULL := 400.0

#const SECONDARY_LINE_ZERO := 80.0
#const SECONDARY_LINE_FULL := 280.0
#
#const SECONDARY_ZERO_STATE := 550.0
#const SECONDARY_FULL_STATE := 350.0

const MAX_CHARGE := 300.0
@export_range(0.0, 1.0, 0.001) var main_charge := 0.0
@export_range(0.0, 1.0, 0.001) var secondary_charge := 0.0
@export var main_gauge_label_value : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	main_gauge.material.set_shader_parameter("end", lerp(MAIN_FULL_STATE, MAIN_ZERO_STATE, 1.0 - main_charge))
	#secondary_gauge.material.set_shader_parameter("end", lerp(SECONDARY_FULL_STATE, SECONDARY_ZERO_STATE, 1.0 - secondary_charge))
	
	main_line.rotation_degrees = lerp(MAIN_LINE_ZERO, MAIN_LINE_FULL, main_charge)
	#secondary_line.rotation_degrees = lerp(SECONDARY_LINE_ZERO, SECONDARY_LINE_FULL, secondary_charge)
	
	main_gauge_label.text = str(main_gauge_label_value)
