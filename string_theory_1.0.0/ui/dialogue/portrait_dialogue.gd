extends Control

@onready var _sprite_2d: Sprite2D = $Border/Frame/Sprite2D
@onready var martian_name: Label = $NinePatchRect/Name

var character := false
var maverick_texture : Texture2D = preload("res://assets/martin_martian.png")
var martin_texture : Texture2D = preload("res://assets/crew.png")
var karen_texture : Texture2D = preload("res://assets/sophia.png")
var roberto_texture : Texture2D = preload("res://assets/roberto.png")

var martin :={
	"name" : "Martin",
	"texture" : martin_texture,
	"new_scale": Vector2(2.3,2.3),
	}

var maverick :={
	"name" : "Maverick",
	"texture" : maverick_texture,
	"new_scale": Vector2(1.15,1.15),
	}

var karen :={
	"name" : "Karen",
	"texture" : karen_texture,
	"new_scale": Vector2(1.6,1.6),
	}

var roberto :={
	"name" : "Roberto",
	"texture" : roberto_texture,
	"new_scale": Vector2(0.35,0.35),
	}

var crew :={0 : martin, 1 : maverick, 2: karen,
	3: roberto,
	}

enum States {
	MARTIN,
	MAVERICK,
	KAREN,
	ROBERTO
	}

var current_state: States = States.MARTIN:
	set = set_current_state

func set_current_state(new_state: States) -> void:
	current_state = new_state
	martian_name.text = crew[current_state]["name"]
	_sprite_2d.texture = crew[current_state]["texture"]
	_sprite_2d.scale = crew[current_state]["new_scale"]

func _ready() -> void:
	_sprite_2d.position.y= 180
	_sprite_2d.modulate.a= 0
	pop_in()

func pop_in() -> void:
	var tween := create_tween()
	tween.tween_property(_sprite_2d, "position:y", 23.0, 0.6).set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_sprite_2d, "modulate:a", 1, 0.8)

func ready_for_pop_in() -> void:
	_sprite_2d.position.y= 180
	_sprite_2d.modulate.a= 0

func pop_out() -> void:
	var tween := create_tween()
	tween.tween_property(_sprite_2d, "position:y", -290.0, 1.0).set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_sprite_2d, "modulate:a", 0, 0.8)
