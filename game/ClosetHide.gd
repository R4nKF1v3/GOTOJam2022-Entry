extends ColorRect

onready var tween:Tween = $Tween

export (String) var closet_key:String


func _ready() -> void:
	show()


func notify_key_progress_unlocked(key_progress:String) -> void:
	if key_progress == closet_key:
		tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1.0)
		tween.start()
		yield(tween, "tween_all_completed")
		hide()
