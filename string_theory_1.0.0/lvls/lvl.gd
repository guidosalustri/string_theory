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
@onready var cut_line: Line2D = $CutLine
@onready var animation_player: AnimationPlayer = $LinkLineShip/AnimationPlayer
#@onready var pick_ups: Node2D = $PickUps
#@onready var pick_crew_ui: Control = $CanvasLayer2/PickCrewUI
@export var canvas_layer_3: CanvasLayer

@export var stars_trail: Array[Star]
#@export var with_pickups := false
#@export var max_string_lenght := 900

var index := 0
#options to cut the link
var lenght_link_line_ship := 0.0
#var width_curve : Curve = null
var thickness := 1.0
var flag_cutline := true

func _ready() -> void:
	hud.player = ship
	hud.set_stars_trail(stars_trail)
	hud.no_energy.connect(func() -> void:
		ship.set_has_energy(false)
	)
	hud.overcharged.connect(_overcharged_ship)
	
	get_tree().paused = false
	_blur.material.set_shader_parameter("blur_amount", 0.0)
	_blur.material.set_shader_parameter("tint_amount", 0.0)
	_blur.material.set_shader_parameter("saturation", 1.0)
	
	ship.star_entered.connect(_on_star_changed)
	ship.cut_link.connect(cut_line_link)
	animation_player.animation_finished.connect(func(_anim_name: StringName) -> void:
		GameManager.data_collection.log_player_death(DataCollection.player_death_cause.STRAY)
		cut_line_link(false)
		ship.animation_player.play("die")
		ship.set_process(false)
		)

	stars_trail[-1].area_entered.connect(func (_area: Area2D):
		if index == stars_trail.size()-1:
			if stars_trail[-1].current_state == stars_trail[-1].States.STAR:
				GameManager.play_in_game_music_end()
				await get_tree().create_timer(0.00000000000001).timeout
				GameManager.data_collection.log_level_start_complete(
					GameManager.lvls[GameManager.lvl].resource_path.get_file(),
					DataCollection.level_status.COMPLETE
				)
				
				phantom_camera_constellation.priority = 3
				ship.set_deferred("monitorable", false)
				ship.set_deferred("monitoring", false)
				ship.is_last_star = true
				ship.get_node("PointLight2D").hide()
				timer.start()
				hud.overcharged.disconnect(_overcharged_ship)
				if canvas_layer_3:
					for child in canvas_layer_3.get_children():
						var tween_tutorial := create_tween()
						tween_tutorial.tween_property(child, "modulate:a", 0, 0.3)
		)
	timer.timeout.connect(_on_timer_timeout)
	#for pickup in pick_ups.get_children():
	#	pickup.has_spawn.connect(func() -> void:
	#		GameManager.pickup_spawn_count+=1
	#		print(GameManager.pickup_spawn_count)
	#		print(GameManager.gems)
	#		)
	
	stars_trail[0].spawn()
	
	#animation_player.play("blink")
	
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
		
		#lenght_link_line_ship = link_line_ship.points[0].distance_to(link_line_ship.points[1])

	adjust_ship_light()
	
	#if lenght_link_line_ship > max_string_lenght and flag_cutline:
	#	flag_cutline = false
	#	cut_line_link()

func _on_star_changed(star: Star)-> void:
	if star != stars_trail[index]:
		GameManager.data_collection.log_player_death(DataCollection.player_death_cause.STAR_COLISSION)
		ship.explode()
		return
	elif not index == stars_trail.size()-1:
		#phantom_camera_constellation.priority = 3
		#timer.start()
		#pass

	#else:
		index +=1
		stars_trail[index].spawn()
		phantom_camera_ship.follow_targets[1] = stars_trail[index]

		if phantom_camera_star.follow_targets.size() >= 2:
			phantom_camera_star.erase_follow_targets(phantom_camera_star.follow_targets[0])
		phantom_camera_star.append_follow_targets(stars_trail[index])
		phantom_camera_ship.priority = 1
		phantom_camera_star.priority = 2
		ship.target_star = stars_trail[index]

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
		particle_link.emitting = false
		particle_link.position = ((new_vector - particles_vector)*0.5) + particles_vector
		particle_link.rotation = get_angle_to(new_vector - particles_vector)
		particle_link.light_pos(particle_link.position)
		particle_link.light_rotation(particle_link.rotation+ (PI/2))
		# the resource need to be unique for each segment of the line, if not there will
		# only be one resource that will be constantly modify and the particles will
		# emit in wierd area (longer or shorter than the line itself)
		particle_link.process_material = particle_link.process_material.duplicate()
		# we set the emitting box to the line size
		particle_link.process_material.emission_box_extents.x = (new_vector - particles_vector).length() * 0.5
		particle_link.light_lenght((new_vector - particles_vector).length())
		await get_tree().create_timer(0.05).timeout
		particle_link.emitting = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spin"):
		phantom_camera_ship.priority = 2
		phantom_camera_star.priority = 1

func _on_timer_timeout() -> void:
	cut_line.hide()
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

	GameManager.lvl += 1
	GameManager.call_cutscene()


func dim_out_obstacles() -> void:
	for star in constellation.get_children():
		for child in star.get_children():
			if child.is_in_group("obstacles") or child.is_in_group("spinner_bh"):
				child.hide()

func _overcharged_ship() -> void:
	GameManager.data_collection.log_player_death(DataCollection.player_death_cause.OVERCHARGE)
	ship.explode()

func adjust_ship_light()-> void:
	if index >0 and index<stars_trail.size():
		var d_ship_nextstar = ship.position.distance_to(stars_trail[index].position)
		var d_ship_star = ship.position.distance_to(stars_trail[index-1].position)
		var half_d_star_star = stars_trail[index].position.distance_to(stars_trail[index-1].position)/2
		if d_ship_star >= half_d_star_star and d_ship_nextstar>=half_d_star_star:
			ship.dim_light_on(false)
			if not animation_player.is_playing():
				animation_player.play("blink")
		else:
			ship.dim_light_on(true)
			if animation_player.is_playing():
				animation_player.stop()

func cut_line_link(was_black_hole: bool) -> void:
	if animation_player.is_playing():
		animation_player.stop()
	link_line_ship.hide()
	if was_black_hole:
		cut_line.target = ship
		if link_line_ship.points[0] != Vector2(0.0,0.0):
			cut_line.create_line(link_line_ship.points[0],link_line_ship.points[1])
	else:
		cut_line.create_line(link_line_ship.points[1],link_line_ship.points[0])
	ship.cut_link.disconnect(cut_line_link)
