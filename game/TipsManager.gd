extends Node

onready var tip_timer:Timer = $TipTimer

export (PoolStringArray) var keys_progression:PoolStringArray
export (PoolStringArray) var keys_tips:PoolStringArray
export (float) var tip_delay:float = 25.0

var keys_stack:Array = []


func _ready() -> void:
	tip_timer.start(50.0)


func notify_key_progress_unlocked(key_progress:String) -> void:
	tip_timer.start(tip_delay)
	if keys_progression.has(key_progress) && !keys_stack.has(key_progress):
		keys_stack.push_back(key_progress)


func _on_TipTimer_timeout() -> void:
	for i in keys_progression.size():
		var key:String = keys_progression[i]
		if !keys_stack.has(key):
			var tip:String = keys_tips[i]
			get_tree().call_group("dialogue", "show_dialogue", [tip])
			break
	
	tip_timer.start(tip_delay)
