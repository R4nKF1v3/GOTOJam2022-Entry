extends Control

onready var text_rect:TextureRect = $TextureRect

export (String) var item_key:String
export (Texture) var item_texture:Texture
export (String) var tooltip:String


func _ready() -> void:
	hide()
	text_rect.texture = item_texture


func notify_key_progress_unlocked(key_progress:String) -> void:
	if key_progress == item_key:
		show()


func _on_mouse_entered() -> void:
	get_tree().call_group("tooltip", "change_tooltip", tooltip)


func _on_mouse_exited() -> void:
	get_tree().call_group("tooltip", "hide_tooltip", tooltip)
