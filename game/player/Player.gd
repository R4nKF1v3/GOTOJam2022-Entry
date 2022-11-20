extends Node2D
class_name Player

export (float) var walk_speed:float = 50.0

var acceleration:float = 0.0

var current_map:RID
var current_path:PoolVector2Array


func _physics_process(delta: float) -> void:
	if !current_path.empty():
		var walked:float = 0.0
		acceleration = min(lerp(acceleration, walk_speed, delta), walk_speed)
		var max_distance:float = acceleration * delta
		var starting_point:Vector2 = global_position
		while walked < max_distance && !current_path.empty():
			var next_point:Vector2 = current_path[0]
			var distance:float = global_position.distance_to(next_point)
			if distance < 1.0:
				current_path.remove(0)
				var dec_factor:float = 0.2
				if !current_path.empty():
					var next:Vector2 = current_path[0]
					var angle:float = abs(starting_point.angle_to(next_point) - next_point.angle_to(next))
					if angle < PI/24.0:
						dec_factor = 1.0
				acceleration *= dec_factor
			else:
				var moved:float = min(distance, max_distance - walked)
				walked += moved
				global_position += (next_point - global_position).normalized() * moved
	else:
		acceleration = 0.0


func _walk_to(global_point:Vector2) -> void:
	current_path = Navigation2DServer.map_get_path(current_map, global_position, global_point, true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		_walk_to(get_global_mouse_position())

