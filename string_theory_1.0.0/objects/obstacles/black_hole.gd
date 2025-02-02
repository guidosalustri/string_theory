extends Area2D

signal black_hole_entered

var is_in_spinner := false
var linear_speed_aprox := 0

func _ready() -> void:
	modulate.a = 0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	area_entered.connect(_on_area_entered)

func activate(time_to_activate: float) -> void:
	var tween:  Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a",0.4,time_to_activate/2)
	await tween.finished
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	var tween2:  Tween = create_tween()
	tween2.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween2.tween_property(self, "modulate:a",0.8,time_to_activate/2)

func blackhole_on() -> void:

	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	modulate.a = 1

func blackhole_off() -> void:

	modulate.a = 0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func _on_area_entered(area: Area2D) -> void:
	black_hole_entered.emit()
