extends Line2D

#@onready var pos1 :Vector2= Vector2(0,0)
#@onready var pos2 :Vector2= Vector2(0,0)
var line_created := false
@export var target : Ship = null
#func _ready() -> void:
#	create_line(pos1,pos2)
	#print(points[-1])

func _physics_process(delta: float) -> void:
	if line_created:
		#if target.global_position.distance_to(points[-1])>5:
		add_point(target.global_position)
		var random_y = Vector2(0,randf_range(-15,15))
		if points.size() > 25:
			points[11] = points[11] + Vector2(0,randf_range(-5,5))
			points[20] = points[20] + Vector2(0,randf_range(-15,15))
	if points.size() > 1:
		remove_point(0)
		

	
func create_line(v1: Vector2) -> void:
	var dir := v1.direction_to(target.global_position)
	var d := v1.distance_to(target.global_position)
	var max_d_between_points := 20
	var n_points := floori(d/max_d_between_points)
	for i in n_points:
		var random_y = Vector2(0,randf_range(-1,1))
		add_point(v1+(dir*max_d_between_points*i)+random_y)
	add_point(target.global_position)
	line_created = true
