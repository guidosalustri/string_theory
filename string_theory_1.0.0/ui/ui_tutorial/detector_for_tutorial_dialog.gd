extends Area2D

@onready var rich_text_label: RichTextLabel = $Control/RichTextLabel

@export var dialog : DialogTutorial
@export_multiline var display_text : String

var _tween: Tween = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	#area_exited.connect(_on_area_exited)


func _on_area_entered(_area:Area2D) -> void:
	play_label()
	if dialog:
		#dialog.play_dialog()
		dialog.allow_input_for_dialog = true
	area_entered.disconnect(_on_area_entered)

func play_label() -> void:
	rich_text_label.text = display_text
	rich_text_label.visible_ratio = 0.0

	_tween = create_tween()
	_tween.tween_property(rich_text_label, "visible_ratio", 1.0, rich_text_label.text.length() / 50.0)

#func _on_area_exited(_area:Area2D) -> void:
#	await _tween.finished
#	
#	_tween = create_tween()
#	_tween.tween_property(rich_text_label, "modulate:a", 0.0, 0.2)
