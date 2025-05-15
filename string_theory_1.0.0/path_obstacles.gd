extends Path2D

@export var move_speed := 0.2
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var asteroid: Area2D = $PathFollow2D/Asteroid
@onready var asteroid_trail: Line2D = $PathFollow2D/Asteroid/AsteroidTrail

var way_back := false

func _ready() -> void:
	set_process(false)
	asteroid_trail.light_collision_on(false)
	asteroid.light_on(false)


func _process(delta: float) -> void:
	if way_back:
		path_follow_2d.progress_ratio -=move_speed*delta
	else:
		path_follow_2d.progress_ratio +=move_speed*delta
	
	if path_follow_2d.progress_ratio == 1:
		way_back=true
		asteroid_trail.hide()
		asteroid_trail.rotation = 0
		await get_tree().create_timer(0.1).timeout
		asteroid_trail.show()
	if path_follow_2d.progress_ratio == 0:
		way_back=false
		asteroid_trail.hide()
		asteroid_trail.rotation = PI
		await get_tree().create_timer(0.1).timeout
		asteroid_trail.show()

func activate(_time_to_activate: float) -> void:
	await get_tree().create_timer(0.1).timeout
	set_process(true)
	asteroid.light_on(true)
	asteroid.activate(_time_to_activate)
	asteroid_trail.power = 1
	asteroid_trail.light_collision_on(true)
	await asteroid.animation_player.animation_finished
	asteroid.animation_player.play("spin")


func deactivate() -> void:
	asteroid.light_off()
	asteroid_trail.light_off()
	var tween:  Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a",0.0,0.6)
