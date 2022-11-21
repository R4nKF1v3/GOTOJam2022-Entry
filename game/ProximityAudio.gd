extends Area2D

onready var audio:AudioStreamPlayer = $Audio

var target:Node2D


func set_active(active:bool) -> void:
	set_physics_process(active)
	audio.playing = active


func _physics_process(delta: float) -> void:
	if target:
		audio.volume_db = clamp(-global_position.distance_to(target.global_position) / 20.0, -80, -10)


func _on_ProximityArea_area_entered(area: Area2D) -> void:
	target = area


func _on_ProximityArea_area_exited(area: Area2D) -> void:
	target = null
