#@tool
extends Control

## Controls how much the menu is opened. This isn't actually used in the running game
## but it allows us to preview the menu animation in the editor.
@export_range(0, 1.0) var menu_opened_amount := 0.0: 
	set = set_menu_opened_amount
## How fast the pause menu opens
@export_range(0.1, 10.0, 0.01, "or greater") var opening_speed := 2.3

@onready var _blur_color_rect: ColorRect = %BlurColorRect
@onready var options: Control = $Options
@onready var portrait: Control = $Options/Portrait
@onready var portrait_2: Control = $Options/Portrait2
@onready var options_button_martin: Button = $Options/CenterContainer/VBoxContainer/OptionsButton1
@onready var options_button_2: Button = $Options/CenterContainer/VBoxContainer/OptionsButton2


var _tween: Tween


func _ready() -> void:

	menu_opened_amount = 0.0
	portrait_2.set_current_state(portrait.States.MAVERICK)
	options_button_martin.pressed.connect(_on_buton_martin_pressed)
	options_button_2.pressed.connect(_on_buton_2_pressed)


## Called when [member menu_opened_amount] is changed.
func set_menu_opened_amount(amount: float) -> void:
	visible = amount > 0
	# we set the value
	menu_opened_amount = amount
	# we ensure the nodes exist (in case the function gets called before _ready)
	if options == null or _blur_color_rect == null:
		return
	# we lerp all the values between 0 and 1, the two regular extremes of the 
	# menu_opened_amount variable.
	# first, the shader. We set the blur amount and the saturation
	_blur_color_rect.material.set_shader_parameter("blur_amount", lerp(0.0, 1.5, amount))
	_blur_color_rect.material.set_shader_parameter("saturation", lerp(1.0, 0.3, amount))
	options.modulate.a = amount

	get_tree().paused = amount > 0.1


func toggle(is_toggled: bool) -> void:
	var speed := opening_speed
	# if there's a tween, and it is animating, kill it.
	# just checking for `null` isn't enough,
	if _tween != null and _tween.is_valid():
		# if the previous tween was animating, we want to animate back by the exact
		# elapsed time
		speed = _tween.get_total_elapsed_time()
		_tween.kill()

	_tween = create_tween()
	# make the tween feel nice
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUART)
	# We want to animate the "menu_opened_amount" property to 1.0 if toggled,
	# or to 0 otherwise
	var target := 1.0 if is_toggled else 0.0
	# We animate the property
	_tween.tween_property(self, "menu_opened_amount", target, speed)
	if is_toggled:
		#await _tween.finished
		await get_tree().process_frame
		portrait.ready_for_pop_in()
		portrait_2.ready_for_pop_in()
		portrait.pop_in()
		portrait_2.pop_in()



func _on_buton_martin_pressed() -> void:
	GameManager.martin_on_ship = true
	toggle(false)

func _on_buton_2_pressed() -> void:
	GameManager.martin_on_ship = false
	toggle(false)
