@tool
class_name EnergyHUD extends VBoxContainer

@onready var left_label: Label = $Numbers/MarginContainer/Left
@onready var middle_label: Label = $Numbers/Middle
@onready var right_label: Label = $Numbers/MarginContainer2/Right

@onready var left_tex: TextureRect = $PanelContainer/Left
@onready var middle_tex: TextureRect = $PanelContainer/Middle
@onready var right_tex: TextureRect = $PanelContainer/Right

@export var level_gradient : Gradient

@export_range (0.0, 1.0) var left_thruster_charge = 0.0:
	set(value):
		if not (left_label && left_tex):
			return
		left_thruster_charge = value
		var color := level_gradient.sample( left_thruster_charge ) if level_gradient else Color.WHITE
		left_label.text = str(int(left_thruster_charge * 100.0))
		left_label.add_theme_color_override("font_color", color )
		left_tex.modulate = color
		
@export_range (0.0, 1.0) var main_thruster_charge = 0.0:
	set(value):
		if not (middle_label && middle_tex):
			return
		main_thruster_charge = value
		var color := level_gradient.sample( main_thruster_charge ) if level_gradient else Color.WHITE
		middle_label.text = str(int(main_thruster_charge * 100.0))
		middle_label.add_theme_color_override("font_color", color )
		middle_tex.modulate = color
@export_range (0.0, 1.0) var right_thruster_charge = 0.0:
	set(value):
		if not (right_label && right_tex):
			return
		right_thruster_charge = value
		var color := level_gradient.sample( right_thruster_charge ) if level_gradient else Color.WHITE
		right_label.text = str(int(right_thruster_charge * 100.0))
		right_label.add_theme_color_override("font_color", color )
		right_tex.modulate = color

