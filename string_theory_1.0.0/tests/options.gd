extends Control

@onready var blur_color_rect: ColorRect = $BlurColorRect

@onready var button_cancel_text: Button = $UIPanelContainer/Controls/VBoxContainer/VBoxContainer/GoBackButton
@onready var button_cancel_audio: Button = $UIPanelContainer/Audio/VBoxContainer2/VBoxContainer/GoBackButton

@onready var bgm_volume_slider: HSlider = $UIPanelContainer/Audio/VBoxContainer2/HBoxContainer/BGMVolumeSlider
@onready var sfx_volume_slider: HSlider = $UIPanelContainer/Audio/VBoxContainer2/HBoxContainer2/SFXVolumeSlider
@onready var music_volume_slider: HSlider = $UIPanelContainer/Audio/VBoxContainer2/HBoxContainer7/VoiceVolumeSlider

#@export var blur_on := false
signal cancel_clicked

func _ready() -> void:
	button_cancel_text.pressed.connect(_on_button_pressed)
	button_cancel_audio.pressed.connect(_on_button_pressed)
	
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_value_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_value_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_value_changed)
	
	#if blur_on:
	#	blur_color_rect.material.set_shader_parameter("blur_amount", 2.5)
	#	blur_color_rect.material.set_shader_parameter("saturation", 1)



func _on_button_pressed() -> void:
	cancel_clicked.emit()

func _on_bgm_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	
