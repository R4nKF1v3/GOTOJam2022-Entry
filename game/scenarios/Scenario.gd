extends Node2D
class_name Scenario

export (NodePath) var camera_path:NodePath
onready var camera:Camera2D = get_node(camera_path)

export (NodePath) var nav_base_path:NodePath
onready var nav_base:Navigation2D = get_node(nav_base_path)

export (AudioStream) var bgm:AudioStream
export (float) var bgm_db:float = -10

var map:RID


func setup() -> void:
	map = nav_base.get_rid()


func set_as_current(player:Player) -> void:
	player.current_map = map
	camera.current = true
	player.current_path = PoolVector2Array()
	player.target = player.global_position
	AudioManager.change_main_bgm(bgm, bgm_db, 1, 1, true)

