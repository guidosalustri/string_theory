## Confetti particles node
##
## This node creates a few confetti-like particles, and immediately removes 
## itself once all particles have disappeared. To show confettis again, simply
## instantiate the class again. This class has no methods and no signals.
## 
@icon("confettis_particles.svg")
class_name ConfettisParticles extends GPUParticles2D


func _ready():
	one_shot = true
	emitting = true
	finished.connect(queue_free)
