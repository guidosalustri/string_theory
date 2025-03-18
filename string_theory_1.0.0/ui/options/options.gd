extends Control

@onready var blur_color_rect: ColorRect = $BlurColorRect

@onready var button_cancel_text: Button = $UIPanelContainer/Controls/VBoxContainer/MarginContainer/GoBackButton
@onready var button_cancel_audio: Button = $UIPanelContainer/Audio/VBoxContainer2/MarginContainer/GoBackButton

@onready var bgm_volume_slider: HSlider = $UIPanelContainer/Audio/VBoxContainer2/MarginContainer2/VBoxContainer/GridContainer/BGMVolumeSlider
@onready var sfx_volume_slider: HSlider = $UIPanelContainer/Audio/VBoxContainer2/MarginContainer2/VBoxContainer/GridContainer/SFXVolumeSlider
@onready var music_volume_slider: HSlider = $UIPanelContainer/Audio/VBoxContainer2/MarginContainer2/VBoxContainer/GridContainer/VoiceVolumeSlider
@onready var auto_advance_dialogue_checkbox: CheckButton = $UIPanelContainer/Audio/VBoxContainer2/MarginContainer2/VBoxContainer/GridContainer/AutoAdvanceDialogueCheckbox

signal cancel_clicked

func _ready() -> void:
	button_cancel_text.pressed.connect(_on_button_pressed)
	button_cancel_audio.pressed.connect(_on_button_pressed)
	
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_value_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_value_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_value_changed)
	
	bgm_volume_slider.value = GameManager.volume_bus_master
	sfx_volume_slider.value = GameManager.volume_bus_sfx
	music_volume_slider.value = GameManager.volume_bus_music

func _on_button_pressed() -> void:
	GameManager.volume_bus_master = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	GameManager.volume_bus_sfx = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	GameManager.volume_bus_music = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	cancel_clicked.emit()

func _on_bgm_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
