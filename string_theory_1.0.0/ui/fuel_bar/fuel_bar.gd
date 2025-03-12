@tool
class_name FuelBar extends Control

@export_range(0.0, 1.0) var charge := 0.5
@export var panels : Array[Panel]
@export var color : GradientTexture1D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var visiblePanels : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for panel in panels:
		panel.hide()
	visiblePanels = charge * float(panels.size())

	for idx in range(0, visiblePanels):
		panels[idx].show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_displayCharge(charge * float(panels.size()))

func _displayCharge(_visible: int) -> void:
	if _visible == visiblePanels:
		return
	
	if _visible - visiblePanels > 0:
		for idx in range(visiblePanels, _visible):
			panels[idx].show()
	else:
		for idx in range(_visible, visiblePanels):
			panels[idx].hide()
	
	var sample := color.gradient.sample(charge)
	
	for panel in panels:
		panel.modulate = sample
	
	visiblePanels = _visible
