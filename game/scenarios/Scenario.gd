extends Node2D
class_name Scenario

export (NodePath) var camera_path:NodePath
onready var camera:Camera2D = get_node(camera_path)

export (NodePath) var nav_base_path:NodePath
onready var nav_base:NavigationPolygonInstance = get_node(nav_base_path)

var map:RID
var region:RID


func _ready() -> void:
	map = Navigation2DServer.map_create()
	region = Navigation2DServer.region_create()
	
	Navigation2DServer.region_set_navpoly(region, nav_base.navpoly)
	Navigation2DServer.region_set_transform(region, transform)
	Navigation2DServer.region_set_map(region, map)
	Navigation2DServer.map_set_active(map, true)


func set_as_current(player:Player) -> void:
	player.current_map = map
	camera.current = true
	player.current_path = PoolVector2Array()

