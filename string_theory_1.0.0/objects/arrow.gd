extends Area2D

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var life_time : float = 1
 
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)
	arrow_off()


func _on_area_entered(_area: Area2D) -> void:
	if _area is Ship:
		_area.max_speed_hud = 1000
		_area.max_speed = 1000
		_area.speed = 1000
		_area.fuel = _area.max_fuel
		arrow_off()

func _on_timer_timeout() -> void:
	arrow_off()

func spawn() -> void:
	show()
	animation_player.play("idel")
	timer.wait_time=life_time
	timer.start()
	set_deferred("monitoring", true)

func arrow_off() -> void:
	hide()
	set_deferred("monitoring", false)

func arrow_lifetime_on_detach() -> void:
	#print_debug()
	timer.stop()
	timer.wait_time=0.2
	timer.start()
