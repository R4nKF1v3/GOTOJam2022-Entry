extends Control

signal strongbox_opened()

export (String) var show_progress_key:String
export (PoolIntArray) var correct_key:PoolIntArray

onready var keys:Array = $Pivot/StrongboxBase/Keypad.get_children()
onready var return_button:Control = $ReturnButton
onready var anim:AnimationPlayer = $AnimationPlayer
onready var lock_sfx:AudioHandler = $LockSFX

var numbers_input:Array = []


func _ready() -> void:
	hide()
	for key in keys:
		key.connect("number_selected", self, "_on_number_selected")


func notify_key_progress_unlocked(key_progress:String) -> void:
	if key_progress == show_progress_key:
		show()


func _on_number_selected(number:int) -> void:
	numbers_input.push_back(number)
	lock_sfx.play(0.0, 0)
	if numbers_input.size() == 4:
		var is_valid:bool = true
		for i in 4:
			is_valid = is_valid && numbers_input[i] == correct_key[i]
		if is_valid:
			return_button.hide()
			anim.play("opened")
		else:
			numbers_input = []
			for key in keys:
				key.reset()
			anim.play("wrong")


func notify_finish() -> void:
	emit_signal("strongbox_opened")
	get_tree().call_group("progress_listeners", "notify_key_progress_unlocked", "strongbox_opened")
	hide()


func _on_ReturnButton_button_up() -> void:
	hide()
