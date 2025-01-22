## Pops confettis in a given radius
##
## ConfettisArea instantiates and triggers some [ConfettisParticles] emitters in
##  a random location within a provided radius. The amount of particles emitters 
## and the radius in which they appear are both customizable.[br]
## The confettis don't trigger all at the same time, but in a staggered manner.
## 
@icon("confettis_area.svg")
class_name ConfettisArea extends Marker2D

const ConfettisParticlesScene := preload("confettis_particles.tscn")

## Emitted when all the confettis have been launched
signal finished


## Determines how many confettis emitters get popped
@export var confettis_amount := 5
## Determines a radius within which random confetti emitters will spawn
@export var confettis_radius := 128.0
## Determines the timing between different confetti emitter popping
@export var confettis_pop_time_delay := 0.5


## Creates a few confetti emitters in random areas in the given radius and pops
## them in a staggered manner, then calls [signal finished].
func pop_confettis() -> void:
	for _i in confettis_amount:
		await get_tree().create_timer(confettis_pop_time_delay).timeout
		var confettis: ConfettisParticles = ConfettisParticlesScene.instantiate()
		confettis.global_position += Vector2.from_angle(randf() * TAU) * confettis_radius
		add_child(confettis)
	await get_tree().create_timer(confettis_pop_time_delay).timeout
	finished.emit()
