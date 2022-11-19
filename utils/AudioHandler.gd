tool
extends Node
class_name AudioHandler

export (bool) var _test setget _set_test
export (int) var _test_index:int = 0 setget _set_test_ind

func _set_test_ind(id:int)->void:
	_test_index = clamp(id, 0, max(_audio_references.size()-1, 0))

func _set_test(_val:bool)->void:
	_test = false
	_run_test()

func _run_test()->void:
	if _audio_references.empty():
		return
	var audio_stream:AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream)
	audio_stream.stream = _audio_references[_test_index]
	audio_stream.volume_db = _get_db_volume(_test_index)
	audio_stream.pitch_scale = _get_pitch_scale(_test_index)
	audio_stream.play()
	audio_stream.connect("finished", self, "_on_audio_test_finished")

func _on_audio_test_finished()->void:
	for child in get_children():
		if child is AudioStreamPlayer && !child.playing:
			remove_child(child)
			child.queue_free()


export (Array, AudioStream) var _audio_references:Array setget _set_audio_ref
export (Array, float) var _db_volumes:Array setget _set_db_vol
export (Array, Array, float) var _pitch_scales:Array setget _set_pitch_sc

func _set_audio_ref(ref:Array)->void:
	_audio_references = ref

func _set_db_vol(vol:Array)->void:
	_db_volumes = vol

func _set_pitch_sc(sc:Array)->void:
	_pitch_scales = sc


## Functions

var timers:Dictionary = {}


func play(delay:float = 0.0, id_override = null, db_override = null, pitch_override = null)->void:
	if delay > 0.0:
		var timer:Timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timers[timer] = [id_override, db_override, pitch_override]
		timer.connect("timeout", self, "_on_play_timer_timeout")
		timer.start(delay)
	else:
		_play(id_override, db_override, pitch_override)


func _on_play_timer_timeout()->void:
	for timer in timers.keys():
		if timer.is_stopped():
			var args:Array = timers[timer]
			call_deferred("callv", "_play", args)
			call_deferred("_remove_timer", timer)


func _remove_timer(timer:Timer)->void:
	if is_a_parent_of(timer):
		timers.erase(timer)
		remove_child(timer)
		timer.queue_free()


func _play(id_override = null, db_override = null, pitch_override = null)->void:
	if !_audio_references.empty():
		var selected_index:int = id_override if id_override != null && id_override is int && id_override >= 0 && id_override < _audio_references.size() else randi() % _audio_references.size()
		var db:float = db_override if db_override != null && (db_override is float || db_override is int) else _get_db_volume(selected_index)
		var pitch:float = pitch_override if pitch_override != null && (pitch_override is float || pitch_override is int) else _get_pitch_scale(selected_index)
		AudioManager.play_sfx(_audio_references[selected_index], db, pitch)


func _get_db_volume(index:int)->float:
	if _db_volumes.size() > index:
		return _db_volumes[index]
	else:
		return 0.0


func _get_pitch_scale(index:int)->float:
	if _pitch_scales.size() > index:
		var pitches:Array = _pitch_scales[index]
		if !pitches.empty():
			return rand_range(pitches[0], pitches[1]) if pitches.size() > 1 else pitches[0]
	return 1.0
