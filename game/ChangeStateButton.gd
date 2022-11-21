extends TextureButton

export (String) var item_key:String


func _ready() -> void:
	hide()


func notify_key_progress_unlocked(key_progress:String) -> void:
	if key_progress == item_key:
		show()
