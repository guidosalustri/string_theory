extends Node2D

@onready var black_hole_2: Area2D = $SpinerBlackHole/blackHole2
@onready var black_hole: Area2D= $SpinerBlackHole/blackHole
@onready var black_hole1: Area2D = $blackHole
@onready var hud: Control = $HUD
@onready var ship: Ship = $Ship
@onready var star: Star = $Star


func _ready() -> void:
	var stars : Array[Star] = [star]
	black_hole.activate(0.3)
	black_hole_2.activate(0.3)
	black_hole1.activate(0.3)
	star.spawn()
	hud.set_player(ship)
	hud.set_stars_trail(stars)


func _process(delta: float) -> void:
	if star.current_state == star.States.BLACK_HOLE:
		print("holaaa")
	if star.current_state == star.States.STAR:
		print("chauuu")
