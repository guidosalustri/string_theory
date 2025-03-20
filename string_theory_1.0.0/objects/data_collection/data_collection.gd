class_name DataCollection extends Node

enum ship_action {
	ATTACH,
	DETACH
}

var ship_action_value := {
	ship_action.ATTACH: "attach",
	ship_action.DETACH: "detach"
}

enum level_status {
	START,
	COMPLETE
}

var level_status_value := {
	level_status.START: "start",
	level_status.COMPLETE: "complete"
}

enum game_quit_cause {
	MENU,
	UNKNOWN
}

var game_quit_cause_value := {
	game_quit_cause.MENU: "menu",
	game_quit_cause.UNKNOWN: "unknown"
}

enum player_death_cause {
	BLACK_HOLE,
	ASTEROID,
	STAR_COLISSION,
	OVERCHARGE,
	OUT_OF_FUEL,
	STRAY
}

var player_death_cause_value := {
	player_death_cause.BLACK_HOLE: "black_hole",
	player_death_cause.ASTEROID: "asteroid",
	player_death_cause.STAR_COLISSION: "star_colission",
	player_death_cause.OVERCHARGE: "overcharge",
	player_death_cause.OUT_OF_FUEL: "out_of_fuel",
	player_death_cause.STRAY: "stray"
}

@onready var stopwatch_util: StopwatchUtil = $StopwatchUtil
@onready var file : FileAccess

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func start_write():
	var path : String
	if OS.has_feature("standalone"):
		var dir := OS.get_executable_path().get_base_dir()
		var datetime_dict := Time.get_datetime_dict_from_system()
		datetime_dict.erase("year")
		datetime_dict.erase("weekday")
		var time := Time.get_datetime_string_from_datetime_dict(datetime_dict, false)
		path = str( dir, "/log_", time, ".csv" )
	else:
		var dir := OS.get_user_data_dir()
		path = str( dir, "/log.csv" )
	print("Storing logs in: ", path)
	
	file = FileAccess.open(path, FileAccess.WRITE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Logging
func log_attach_detach_to_star( action: ship_action, energy_level_normalized: float ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _attach_detach_to_star( time, action, energy_level_normalized ) )
	file.flush()

func log_level_start_complete( level_name: String, status: level_status ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _level_start_complete(time, level_name, status))
	file.flush()

func log_game_complete( ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _game_complete(time))
	file.flush()

func log_game_quit( cause: game_quit_cause = game_quit_cause.UNKNOWN  ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _game_quit(time, cause) )
	file.flush()

func log_level_quit( ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _level_quit(time) )
	file.flush()

func log_player_death( cause: player_death_cause ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _player_death(time, cause) )
	file.flush()

func log_run_out_of_fuel( ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _run_out_of_fuel(time))
	file.flush()

func log_player_pos( pos: Vector2 ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _player_pos(time, pos.x, pos.y))
	file.flush()

# String generator
func _attach_detach_to_star( timestamp: int, action: ship_action, energy_level_normalized: float ) -> String:
	return str( "[sad], ", str(timestamp), ", ", ship_action_value[action], ", ", str(energy_level_normalized), "\n" )

func _level_start_complete( timestamp: int, level_name: String, status: level_status ) -> String:
	return str( "[elsc], ", str(timestamp), ", ",  level_name, ", ", level_status_value[status], "\n" )

func _game_complete( timestamp: int ) -> String:
	return str("[gc], ", str(timestamp), "\n")

func _game_quit( timestamp: int, cause: game_quit_cause ) -> String:
	return str("[gq], ", str(timestamp), ", ", game_quit_cause_value[cause], "\n")

func _level_quit( timestamp: int ) -> String:
	return str("[lq], ", str(timestamp), "\n")

func _player_death( timestamp: int, cause: player_death_cause) -> String:
	return str("[pd], ", str(timestamp), ", ", player_death_cause_value[cause], "\n")

func _run_out_of_fuel( timestamp: int ) -> String:
	return str("[rof], ", str(timestamp), "\n")

func _player_pos( timestamp: int, x: float, y: float ) -> String:
	return str("[pos], ", str(timestamp), ", ", str(x), ", ", str(y), "\n")
