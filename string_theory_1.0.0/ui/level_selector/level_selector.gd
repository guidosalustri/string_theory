extends Node2D

@onready var wheel_items : Array[Node2D] = [
	$Wheel/Capricorn,
	$Wheel/Aquarius,
	$Wheel/Pisces,
	$Wheel/Aries,
	$Wheel/Cancer,
	$Wheel/Gemini,
	$Wheel/Leo,
	$Wheel/Libra,
	$Wheel/Sagittarius,
	$Wheel/Scorpio,
	$Wheel/Taurus,
	$Wheel/Virgo
]

@onready var wheel: Node2D = $Wheel
@onready var lvl_btn: Area2D = $Wheel/LevelButton

@onready var select_animation: Tween


var mouse_pos := Vector2.ZERO
var selected_item : Node2D = null
var unlocked_lvls := [0,2,6]


func _ready() -> void:
	lvl_btn.connect("pressed", func() -> void:
		if selected_item:
			GameManager.lvl = selected_item.level_idx
			GameManager.call_cutscene()
	)
	for item in wheel_items:
		if not item.level_idx in unlocked_lvls:
			item.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = event.global_position
		var mouse_dist_to_wheel_center := mouse_pos.distance_to( wheel.global_position )
		if 100 < mouse_dist_to_wheel_center and mouse_dist_to_wheel_center < 360:
			set_process(true)
		else:
			if mouse_dist_to_wheel_center > 300:
				if selected_item:
					selected_item.unfocus()
					selected_item = null

				lvl_btn.level_name.text = "CHOOSE A LEVEL"
			set_process(false)

func _process(_delta: float) -> void:
	var closest_item := _find_closest_item()
	if closest_item != selected_item:
		if selected_item:
			selected_item.unfocus()
		selected_item = closest_item

		selected_item.focus()
		lvl_btn.set_level_name( selected_item.name )

func _find_closest_item() -> Node2D:
	assert( wheel_items.size() > 0 && "No items in the level selection wheel" )
	var item := wheel_items[0]
	var dist_squared : float = item.global_position.distance_squared_to(mouse_pos)
	for item_idx in range( 1, wheel_items.size() ):
		if wheel_items[ item_idx ].visible:
			var curr_item := wheel_items[ item_idx ]
			var item_mouse_dist_squared = curr_item.global_position.distance_squared_to(mouse_pos)
			if item_mouse_dist_squared < dist_squared:
				item = curr_item
				dist_squared = item_mouse_dist_squared

	return item
