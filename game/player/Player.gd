extends Node2D
class_name Player

signal changed_target(target)
signal stopped_moving()

onready var body:AnimatedSprite = $Pivot/Body
onready var legs:AnimatedSprite = $Pivot/Legs
onready var footsteps_sfx:AudioHandler = $FootstepsSFX

export (Array, SpriteFrames) var old_sprites:Array
export (Array, SpriteFrames) var young_sprites:Array

export (float) var old_walk_speed:float = 30.0
export (float) var young_walk_speed:float = 50.0
export (float) var old_anim_speed:float = 0.5
export (float) var young_anim_speed:float = 1.0

var walk_speed:float
var acceleration:float = 0.0

var current_map:RID
var current_path:PoolVector2Array

var moving:bool = false

onready var target:Vector2 = global_position


func _ready() -> void:
	toggle_state(false)
	_toggle_move(false)


func _physics_process(delta: float) -> void:
	var curr_direction:Vector2 = Vector2.RIGHT.rotated(body.rotation)
	var direction:Vector2 = (target - global_position).normalized()
	if !current_path.empty():
		moving = true
		_toggle_move(true)
		var walked:float = 0.0
		acceleration = min(lerp(acceleration, walk_speed, delta * 4.0), walk_speed)
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
				var moved:float = min(distance - 0.5, max_distance - walked)
				walked += moved
				direction = (next_point - global_position).normalized()
				global_position += direction * moved
	else:
		if moving:
			emit_signal("stopped_moving")
			moving = false
			_toggle_move(false)
		acceleration = 0.0
	
	body.rotation = curr_direction.slerp(direction, delta * 4.0).angle()
	legs.rotation = curr_direction.slerp(direction, delta * 32.0).angle()


func _toggle_move(move:bool) -> void:
	for part in [body, legs]:
		part.playing = move
		if !move:
			part.frame = 0


func toggle_state(is_young:bool) -> void:
	var parts:Array = [body, legs]
	var frames:Array = young_sprites if is_young else old_sprites
	for i in 2:
		var part:AnimatedSprite = parts[i]
		part.speed_scale = young_anim_speed * float(is_young) + old_anim_speed * float(!is_young)
		part.frames = frames[i]
		walk_speed = young_walk_speed * float(is_young) + old_walk_speed * float(!is_young)


func _walk_to(global_point:Vector2) -> void:
	target = global_point
	current_path = Navigation2DServer.map_get_path(current_map, global_position, target, true, 1)
	emit_signal("changed_target", target)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_pressed():
		_walk_to(get_global_mouse_position())


func _on_Legs_frame_changed() -> void:
	var frame:int = legs.frame
	if frame == 2 || frame == 5:
		footsteps_sfx.play()
