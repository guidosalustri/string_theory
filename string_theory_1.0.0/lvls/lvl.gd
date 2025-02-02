extends Node2D

# there are 2 lines one always goes from the ship to the star,
# the other link the stars the ship had traversed
@onready var link_line_ship: Line2D = $LinkLineShip
@onready var link_line_stars: Line2D = $LinkLineStars

@onready var ship: Area2D = $Ship
# the camera swaps from ship to star to ship to next star (each star frame the camera in that star and the next one)
# maybe it will be better for each entity to has its own camera
@onready var camera_2d: Camera2D = $Camera2D

@onready var phantom_camera_ship: PhantomCamera2D = $PhantomCamera2D
@onready var phantom_camera_star: PhantomCamera2D = $PhantomCameraStars
@onready var phantom_camera_constellation: PhantomCamera2D = $PhantomCamera2D2


@onready var timer: Timer = $Timer

@onready var particles_scene : PackedScene = preload("res://assets/link_gpu_particles_2d.tscn")
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var _label: RichTextLabel = $CanvasLayer/RichTextLabel
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var _blur: ColorRect = $CanvasLayer/Blur
@onready var hud: Control = $CanvasLayer/HUD
@onready var constellation: Node2D = $Constellation


@export var stars_trail: Array[Star]

var index := 0

func _ready() -> void:
	hud.set_player(ship)
	hud.set_stars_trail(stars_trail)
	hud.no_energy.connect(func() -> void:
		ship.set_has_energy(false)
		)
	hud.overcharged.connect(_overcharged_ship)
	
	get_tree().paused = false
	_blur.material.set_shader_parameter("blur_amount", 0.0)
	_blur.material.set_shader_parameter("tint_amount", 0.0)
	_blur.material.set_shader_parameter("saturation", 1.0)
	
	ship.change_star.connect(_on_star_changed)
	ship.cut_link.connect( func () -> void:
		link_line_ship.hide()
	)
	stars_trail[-1].area_entered.connect(func (_area: Area2D):
		if index == stars_trail.size()-1:
			if stars_trail[-1].current_state == stars_trail[-1].States.STAR:
				phantom_camera_constellation.priority = 3
				ship.monitorable = false
				ship.monitoring = false
				timer.start()
				hud.overcharged.disconnect(_overcharged_ship)
		)
	timer.timeout.connect(_on_timer_timeout)
	
	stars_trail[0].spawn()
	
	phantom_camera_ship.set_auto_zoom(true)
	phantom_camera_ship.set_auto_zoom_min(0.4)
	phantom_camera_ship.set_auto_zoom_max(1)
	phantom_camera_ship.set_auto_zoom_margin(Vector4(90, 90, 90, 90))
	phantom_camera_ship.priority = 2
	
	phantom_camera_star.append_follow_targets(stars_trail[0])
	phantom_camera_star.set_auto_zoom(true)
	phantom_camera_star.set_auto_zoom_min(0.4)
	phantom_camera_star.set_auto_zoom_max(1)
	phantom_camera_star.set_auto_zoom_margin(Vector4(90, 90, 90, 90))
	phantom_camera_star.priority = 1

	for star in constellation.get_children():
		phantom_camera_constellation.append_follow_targets(star)

	phantom_camera_constellation.priority = 0

func _process(_delta: float) -> void:
	if link_line_ship.points[0] != Vector2(0.0,0.0):
		link_line_ship.points[1] = ship.global_position
	# u have fail in GameManager.deaths_counts universes
	#print(GameManager.deaths_counts)


func _on_star_changed(star: Star)-> void:
	if star != stars_trail[index]:
		ship.explote()
	elif index == stars_trail.size()-1:
		phantom_camera_constellation.priority = 3
		timer.start()

	else:
		index +=1
		stars_trail[index].spawn()
		phantom_camera_ship.follow_targets[1] = stars_trail[index]

		if phantom_camera_star.follow_targets.size() >= 2:
			phantom_camera_star.erase_follow_targets(phantom_camera_star.follow_targets[0])
		phantom_camera_star.append_follow_targets(stars_trail[index])
		phantom_camera_ship.priority = 1
		phantom_camera_star.priority = 2



	var new_vector := star.global_position
	link_line_ship.points[0] = new_vector
	# particle vector is the last star pos,
	# if there is no star the new star becomes particle vector
	var particles_vector := new_vector
	if link_line_stars.points.size() > 0:
		particles_vector = link_line_stars.points[-1]
	
	#new star pos added to the list of points
	link_line_stars.add_point(new_vector)

	# if we have a line we create particles, set its position and rotation
	if particles_vector != new_vector:
		var particle_link = particles_scene.instantiate()
		link_line_stars.add_child(particle_link)
		particle_link.emitting = true
		particle_link.position = ((new_vector - particles_vector)*0.5) + particles_vector
		particle_link.rotation = get_angle_to(new_vector - particles_vector)

		# the resource need to be unique for each segment of the line, if not there will
		# only be one resource that will be constantly modify and the particles will
		# emit in wierd area (longer or shorter than the line itself)
		particle_link.process_material = particle_link.process_material.duplicate()
		# we set the emitting box to the line size
		particle_link.process_material.emission_box_extents.x = (new_vector - particles_vector).length() * 0.5


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spin"):
		phantom_camera_ship.priority = 2
		phantom_camera_star.priority = 1

func _on_timer_timeout() -> void:

	var tween_hud := create_tween()
	tween_hud.tween_property(hud, "modulate:a", 0, 0.5)
	dim_out_obstacles()
	ship.ray_cast_2d.enabled = true
	await get_tree().create_timer(0.5).timeout

	var tween_label := create_tween()
	tween_label.tween_property(_label, "visible_ratio", 1.0, 0.5)
	await tween_label.finished
	await get_tree().create_timer(0.5).timeout

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(color_rect, "modulate", Color.BLACK, 2)
	await tween.finished

	GameManager.lvl +=1
	GameManager.call_cutscene()

func dim_out_obstacles() -> void:
	for star in constellation.get_children():
		for child in star.get_children():
			if child.is_in_group("obstacles") or child.is_in_group("spinner_bh"):
				child.hide()

func _overcharged_ship() -> void:
		ship.explote()
