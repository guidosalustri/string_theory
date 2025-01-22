#@tool
## Individual button representing one combat action.
class_name ActionTextureButton extends TextureButton

### Image used as a button icon.
#@export var icon_texture: Texture2D = null: set = set_icon_texture
### Text used as the button's label.
@export var text := "": set = set_text
#
#@onready var _icon_texture_rect: TextureRect = %IconTextureRect
@onready var _label: Label = %Label
#
#
func set_text(new_text: String) -> void:
	text = new_text
	# wait in case the value is assigned before the childen are ready
	if not is_inside_tree():
		await ready
	_label.text = text
#
#
#func set_icon_texture(new_icon_texture: Texture2D) -> void:
#	icon_texture = new_icon_texture
#	# wait in case the value is assigned before the childen are ready
#	if not is_inside_tree():
#		await ready
#	_icon_texture_rect.texture = icon_texture
