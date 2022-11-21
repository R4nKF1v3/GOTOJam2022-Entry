extends Scenario

onready var closet_col:StaticBody2D = $Walls/ClosetDoorCol
onready var nav_closet:NavigationPolygonInstance = $Navigation2D/NavCloset

onready var closet_light:Node2D = $Lights/ClosetLight

export (String) var closet_door_key:String


func _ready() -> void:
	closet_light.hide()


func notify_key_progress_unlocked(key_progress:String) -> void:
	if key_progress == closet_door_key:
		closet_col.set_collision_layer_bit(0, false)
		closet_col.set_collision_mask_bit(0, false)
		closet_col.hide()
		nav_closet.enabled = true
		closet_light.show()
		closet_light.update()
