extends Control

@onready var options_screen: Control = $options
@onready var main_menu_ui: Control = $MainMenuUI
@onready var credits_page: Control = $CreditsPage

func _ready() -> void:
	options_screen.hide()
	main_menu_ui.options_clicked.connect(_on_options_clicked)
	main_menu_ui.credits_clicked.connect(_on_credits_clicked)
	options_screen.cancel_clicked.connect(_on_cancel_clicked)
	credits_page.credits_over.connect(_on_credits_over)

	GameManager.lvl = 0

func _on_options_clicked() -> void:
	main_menu_ui.hide()
	options_screen.show()

func _on_cancel_clicked() -> void:
	options_screen.hide()
	main_menu_ui.show()
	main_menu_ui._set_buttons_disabled(false)

func _on_credits_over() -> void:
	main_menu_ui.show()

func _on_credits_clicked() -> void:
	main_menu_ui.hide()
	credits_page.start_show()
