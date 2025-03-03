extends Node2D

@onready var dialogue_selector: Control = $DialogueSelector
@onready var options: Control = $Options
@onready var portrait: Control = $Options/Portrait
@onready var portrait_2: Control = $Options/Portrait2
@onready var options_button_martin: Button = $Options/CenterContainer/VBoxContainer/OptionsButton1
@onready var options_button_2: Button = $Options/CenterContainer/VBoxContainer/OptionsButton2



func _ready() -> void:
	portrait_2.set_current_state(portrait.States.ROBERTO)
	options.hide()
	dialogue_selector.dialogue_done.connect(func() -> void:
		options.show()
		options_button_martin.grab_focus()
		portrait.ready_for_pop_in()
		portrait_2.ready_for_pop_in()
		portrait.pop_in()
		portrait_2.pop_in()
		)
	options_button_martin.pressed.connect(_on_buton_martin_pressed)
	options_button_2.pressed.connect(_on_buton_2_pressed)

func _on_buton_martin_pressed() -> void:
	GameManager.martin_on_ship = true
	GameManager.call_cutscene()
	#GameManager.start_lvl(GameManager.lvl)

func _on_buton_2_pressed() -> void:
	GameManager.martin_on_ship = false
	GameManager.call_cutscene()
	#GameManager.start_lvl(GameManager.lvl)
