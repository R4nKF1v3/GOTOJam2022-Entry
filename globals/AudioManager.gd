tool
extends Node

onready var bgm_tween:Tween = $BGMTween
onready var sfx_container:Node = $SfxContainer

export (int) var initial_pool_size:int = 10
export (String) var bgm_bus:String
export (String) var sfx_bus:String

var current_bgm:AudioStreamPlayer
var streams_used:Dictionary = {}
var streams_pool:Array = []


func _ready() -> void:
	for _i in initial_pool_size:
		var audio_stream:AudioStreamPlayer = AudioStreamPlayer.new()
		sfx_container.add_child(audio_stream)
		streams_pool.push_back(audio_stream)


func change_main_bgm(audio:AudioStream, db:float = 0.0, pitch_scale:float = 1.0, transition:float = 1.0, keep_duration:bool = false)->void:
	bgm_tween.remove_all()
	if current_bgm != null && current_bgm.stream == audio:
		bgm_tween.interpolate_property(current_bgm, "volume_db", current_bgm.volume_db, db, transition)
	else:
		var duration:float = 0.0
		if current_bgm != null:
			bgm_tween.interpolate_property(current_bgm, "volume_db", current_bgm.volume_db, -100.0, transition)
			_remove_stream(current_bgm, transition)
			duration = current_bgm.get_playback_position()
		current_bgm = _get_audio_stream()
		current_bgm.stream = audio
		current_bgm.volume_db = -100.0
		current_bgm.pitch_scale = pitch_scale
		current_bgm.bus = bgm_bus
		current_bgm.call_deferred("play", duration if keep_duration else 0.0)
		
		bgm_tween.interpolate_property(current_bgm, "volume_db", -100.0, db, transition)
	
	bgm_tween.start()


func clean_sfx(delay:float = 1.0) -> void:
	for sfx in sfx_container.get_children():
		_remove_stream(sfx, delay)


func play_sfx(audio:AudioStream, db:float = 0.0, pitch_scale:float = 1.0)->void:
	var stream:AudioStreamPlayer
	if streams_used.has(audio):
		var existing:AudioStreamPlayer = streams_used[audio]
		if existing.volume_db < db + 5.0:
			if existing.get_playback_position() < 0.05:
				existing.volume_db = db
				existing.pitch_scale = pitch_scale
				return
			else:
				stream = streams_used[audio]
		else:
			return
	else:
		stream = _get_audio_stream()
		if !stream.is_connected("finished", self, "_on_sfx_stream_finished"):
			stream.connect("finished", self, "_on_sfx_stream_finished")
		streams_used[audio] = stream
	stream.stream = audio
	stream.volume_db = db
	stream.pitch_scale = pitch_scale
	stream.bus = sfx_bus
	stream.call_deferred("play")


func _on_sfx_stream_finished()->void:
	for audio in streams_used.keys():
		var stream:AudioStreamPlayer = streams_used[audio]
		if !stream.playing:
			streams_used.erase(audio)
			_remove_stream(stream)


func _remove_stream(stream:AudioStreamPlayer, delay:float = 0.0)->void:
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	
	if stream.is_connected("finished", self, "_on_sfx_stream_finished"):
		stream.disconnect("finished", self, "_on_sfx_stream_finished")
	stream.stop()
	streams_pool.push_back(stream)


func _get_audio_stream() -> AudioStreamPlayer:
	if streams_pool.empty():
		var stream:AudioStreamPlayer = AudioStreamPlayer.new()
		sfx_container.add_child(stream)
		return stream
	else:
		return streams_pool.pop_back()

