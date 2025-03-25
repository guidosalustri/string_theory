class_name DataCollectionImpl extends DataCollection

var stopwatch_util: StopwatchUtil
var file : FileAccess

func start_write():
	game_paused.connect( func (value: bool) -> void: stopwatch_util.set_paused(value) )
	stopwatch_util = find_child("StopwatchUtil")
	
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

# Logging
func log_attach_detach_to_star( action: ship_action, energy_level_normalized: float ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _attach_detach_to_star( time, action, energy_level_normalized ) )
	file.flush()

func log_aim_score( aim_score: float ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _aim_score(time, aim_score) )
	file.flush()

func log_level_start_complete( level_name: String, status: level_status ) -> void:
	if status == level_status.START:
		if stopwatch_util.is_stopped():
			stopwatch_util.start()
		stopwatch_util.set_paused(false)
	
	if status == level_status.COMPLETE:
		stopwatch_util.set_paused(true)
	
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
	stopwatch_util.stop()
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

func log_player_pos( pos: Vector2, rotation: float ) -> void:
	var time := int(stopwatch_util.time() * 1000.0)
	file.store_string( _player_pos(time, pos.x, pos.y, rotation) )
	file.flush()

# String generator
func _attach_detach_to_star( timestamp: int, action: ship_action, energy_level_normalized: float ) -> String:
	return str( "[sad], ", str(timestamp), ", ", ship_action_value[action], ", ", str(energy_level_normalized), "\n" )

func _aim_score( timestamp: int, aim_score: float ) -> String:
	return str( "[as], ", str(timestamp), ", ", str(aim_score), "\n" )

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

func _player_pos( timestamp: int, x: float, y: float, rotation: float ) -> String:
	return str("[pos], ", str(timestamp), ", ", str(x), ", ", str(y), ", ", rotation, "\n")
