#@tool

class_name ActionTextureButton extends TextureButton


### Text used as the button's label.
@export var text := "": set = set_text

@onready var _label: Label = %Label
#
#
func set_text(new_text: String) -> void:
	text = new_text
	# wait in case the value is assigned before the childen are ready
	if not is_inside_tree():
		await ready
	_label.text = text
