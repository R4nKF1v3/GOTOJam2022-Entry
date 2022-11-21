extends Label

onready var text_timer:Timer = $TextTimer
onready var delay_timer:Timer = $DelayTimer
onready var fade_tween:Tween = $FadeTween
onready var text_sfx:AudioHandler = $TextSFX

var full_dialogue:PoolStringArray
var dialogue_speed:float

var dialogue_nospace:String


func _ready() -> void:
	text = ""


func show_dialogue(dialogue:PoolStringArray, _dialogue_speed:float = 0.1) -> void:
	self.dialogue_speed = _dialogue_speed
	fade_tween.remove_all()
	delay_timer.stop()
	modulate.a = 1.0
	full_dialogue = dialogue
	if !dialogue.empty():
		_set_new_text(full_dialogue[0])
		full_dialogue.remove(0)


func _set_new_text(tx:String) -> void:
	text = tx
	visible_characters = 0
	text_timer.start(dialogue_speed)
	
	dialogue_nospace = tr(tx).replace(" ", "")


func _on_TextTimer_timeout() -> void:
	if visible_characters < dialogue_nospace.length():
		visible_characters += 1
		text_sfx.play()
	else:
		text_timer.stop()
		delay_timer.start(1.0 + 1.5 * float(full_dialogue.empty()))


func _on_DelayTimer_timeout() -> void:
	if full_dialogue.empty():
		fade_tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		fade_tween.start()
	else:
		_set_new_text(full_dialogue[0])
		full_dialogue.remove(0)

