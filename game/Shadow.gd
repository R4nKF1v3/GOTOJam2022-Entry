extends Node2D

onready var spawn_timer:Timer = $SpawnTimer
onready var fade_anim:AnimationPlayer = $AnimationPlayer

export (NodePath) var spawn_points_path:NodePath
onready var spawn_points:Array = get_node(spawn_points_path).get_children()

export (PoolRealArray) var spawn_variation:PoolRealArray


func _ready() -> void:
	_play_timer()


func _play_timer() -> void:
	spawn_timer.start(rand_range(spawn_variation[0], spawn_variation[1]))


func _on_SpawnTimer_timeout() -> void:
	var random_point:Vector2 = spawn_points[randi()%spawn_points.size()].global_position
	global_position = random_point
	rotation = rand_range(0, PI*2)
	fade_anim.play("fade_anim")
