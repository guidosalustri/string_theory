extends Sprite2D


@export var size := 100.0:
	set(value):
		size = value
		scale = Vector2.ONE / texture.get_size() * size
		material.set_shader_parameter("bounds_half_length", size / 2.0)

@export var radius := 12.0:
	set(value):
		radius = value
		material.set_shader_parameter("halo_radius", radius)

@export var halo_color := Color.WHITE:
	set(value):
		halo_color = value
		material.set_shader_parameter("halo_color", halo_color)
