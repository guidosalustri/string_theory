# Code from GDQuest

# Draws a curve representing a thruster flame and controls the power and angle of the thruster.
# To make this work as a component we can attach to the ship, this script reads the input from the player and updates the thruster's power and angle accordingly.
# The code is quite complex for this stage in the course. We're leaving some comments mostly for reference,
# but don't worry if you don't understand everything yet.
# The @tool annotation tells Godot to run the script in the editor, so we can see the thruster's flame 
# while we're working on it.
@tool
extends Line2D

# We use curves to control the size and opacity of the thruster flame.
# Curves are a tool provided by Godot that lets us map a value to another value.
# For example, the size curve maps the position along the thruster to a given thickness.
@export var size_curve: Curve
@export var alpha_curve: Curve
@export var max_length := 160.0
@export var power := 1.0:
	set(value):
		power = clamp(value, 0.0, 1.0)
		# Here we use what we call a "null" check to see if the curves are present.
		# This is a defensive style of programming, which we use mostly so you don't risk
		# facing errors when you try to use the thruster in the course.
		if size_curve != null:
			length = size_curve.sample(power)
		if gpu_particles_2d != null:
			gpu_particles_2d.emitting = power > 0.45
		if alpha_curve != null:
			self_modulate.a = alpha_curve.sample(power)
@export var curl := 0.0:
	set(value):
		curl = value
		_do_redraw = true

var length := 100.0:
	set(value):
		length = value * max_length
		_do_redraw = true
var resolution : int = 3

var _last_frame_rotation := global_rotation
var _angle_difference_smoothed := 0.0
# This variable is used to avoid redrawing the thruster's flame multiple times per frame.
# It's a coding pattern called "lazy evaluation" or "dirty flag" and it's used to ensure 
# we only run calculations when necessary.
var _do_redraw := false
var thruster_on := false


@onready var gpu_particles_2d = %GPUParticles2D


func _ready() -> void:
	_update_drawing()
	gpu_particles_2d.emitting = Engine.is_editor_hint()
	if not Engine.is_editor_hint():
		power = 0.0
		#const REQUIRED_ACTIONS := ["move_left", "move_right", "move_up", "move_down"]
		#const ERROR_STUB := "The action %s is missing from the Input Map. For the thrusters to work, you need to have these actions defined in the Input Map: %s. See the Output bottom panel for more information."
		#const MESSAGE := """[color=orange]Error: The action %s is missing from the Input Map. For the thrusters to work, you need to have these actions defined in the Input Map: %s.[/color]

#If you named your input actions differently, the practices and the thrusters won't work. You can change the action names in Project -> Project Settings... -> Input Map.

#If you don't want to change the action names, you will need to change the action names in this script and in all interactive practices to match the ones you defined in the Input Map. We only recommend doing this if you're already experienced in programming."""
		#for action in REQUIRED_ACTIONS:
		#	if not InputMap.has_action(action):
		#		print_rich(MESSAGE % [action, ", ".join(REQUIRED_ACTIONS)])
		#	assert(InputMap.has_action(action), ERROR_STUB % [action, ", ".join(REQUIRED_ACTIONS)])


func _process(delta: float) -> void:
	# We only want to update the thruster's power and angle if we're not in the editor, as it
	# depends on the player's input. This conditional statement checks if we're in the editor.
	if not Engine.is_editor_hint():
		# We use the Input class to read the player's input.
		# The function Input.get_vector() calculates a _normalized_ vector from the input actions we pass to it.
		# It's a shorter way to do the same thing we did in the lessons with Input.get_axis() and direction.normalized().
		# It's a convenient shortcut for some top-down and 3D games, though you can use Input.get_axis() in more cases.
		#var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# We use the lerp() function to smoothly change the thruster's power.
		#if direction.length() > 0.0:
		if thruster_on:
			power = lerp(power, 1.0, 10.0 * delta)
		else:
			power = max(0.0, power - 2.0 * delta)

		# This calculates the angle difference between the thruster's current rotation and the rotation in the last frame.
		# We use this to make the thruster's flame curl in the direction of the ship's movement.
		var angle_delta := wrapf(_last_frame_rotation - global_rotation, -PI, PI)
		_last_frame_rotation = global_rotation
		_angle_difference_smoothed = lerp_angle(_angle_difference_smoothed, angle_delta, 8.0 * delta)
		curl = _angle_difference_smoothed * 8.0

	# Here is where we check if we need to redraw the thruster's flame, which happens at most once per frame.
	if _do_redraw:
		_do_redraw = false
		_update_drawing()


# This function updates the thruster's flame drawing when called.
# This script is attached to a Line2D node, which is a 2D drawing node that can be used to draw lines with different thicknesses and colors.
# We can add points to the line to make it draw a curve.
func _update_drawing():
	width = length * 0.45
	var new_points := PackedVector2Array([Vector2(0, 0)])
	new_points.resize(resolution)
	var segment_length = length / float(resolution)
	for index in range(1, resolution):
		var ratio := index / float(resolution - 1)
		var point_previous := new_points[index - 1]
		new_points[index] = Vector2.from_angle(curl * ratio) * segment_length + point_previous

	points = new_points
