@tool
extends Control

# We right-clicked on the word Color and clicked Pick Color to sample the colors
# below. We use the constants inupdate_health_bar() below.

const MAX_HEALTH := 100

## The color of the health bar when it is low
@export var color_health_low := Color(0.690196, 0.188235, 0.360784)

## The color of the health bar when it is high
@export var color_health_high := Color(0.560784, 0.870588, 0.364706)

## This property keeps track of the current health, and its setter triggers the
## tween animation.
#ANCHOR:health_prop
@export_range(0, 100) var health := 50:
	set = set_health
#END:health_prop

#ANCHOR:node_ref
@onready var _texture_progress_bar: TextureProgressBar = %TextureProgressBar
#END:node_ref

func _ready() -> void:
	update_health_bar(health)


func _on_heal_button_pressed() -> void:
	set_health(health + 10)


func _on_damage_button_pressed() -> void:
	set_health(health - 10)


## Setter for the health value, runs anytime [member health] changes
#ANCHOR:set_health_signature
func set_health(value: int) -> void:
#END:set_health_signature
	# the setter can run before the node is in the tree, so we need a check
	if not is_inside_tree():
		await ready
#ANCHOR:set_health_body
	# save the previous value to use it in the tween
	var previous_health := health
	# limit the `health` within the bar's value range.
	health = int(clamp(value, 0, MAX_HEALTH))
	
	var tween = create_tween()
	# this will call `update_health_bar` repeatedly, with values going from
	# the current health to the health value we just got
	tween.tween_method(update_health_bar, float(previous_health), float(health), 0.33)
#END:set_health_body


#ANCHOR:update_health_bar
func update_health_bar(health_target: float) -> void:
	_texture_progress_bar.value = health_target
	# calculate the current ratio of progress:
	var ratio := health_target / MAX_HEALTH
	# `ProgressBar` has a `tint_progress` property that we can use to color the 
	# middle part.
	_texture_progress_bar.tint_progress = color_health_low.lerp(color_health_high, ratio)
#END:update_health_bar
