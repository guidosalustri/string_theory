extends GPUParticles2D

@onready var point_light_2d: PointLight2D = $PointLight2D


func light_pos(pos: Vector2) -> void:
	point_light_2d.global_position = pos

func light_rotation(rot: float) -> void:
	point_light_2d.global_rotation = rot

func light_lenght(distance: float) -> void:
	point_light_2d.texture.height = distance
