extends TabContainer

@onready var button_cancel_text: Button = $Text/HBoxContainer/ButtonCancel
@onready var button_cancel_audio: Button = $Audio/HBoxContainer/ButtonCancel

@onready var bgm_volume_slider: HSlider = $Audio/ScrollContainer/VBoxContainer/HBoxContainer/BGMVolumeSlider

signal cancel_clicked

func _ready() -> void:
	button_cancel_text.pressed.connect(_on_button_pressed)
	button_cancel_audio.pressed.connect(_on_button_pressed)
	
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_value_changed)



func _on_button_pressed() -> void:
	cancel_clicked.emit()

func _on_bgm_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	
	
	
	
