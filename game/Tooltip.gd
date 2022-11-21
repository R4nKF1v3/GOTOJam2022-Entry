extends Node2D

onready var label:Label = $Tooltip
onready var fade_tween:Tween = $FadeTween


func _ready() -> void:
	modulate.a = 0.0


func _process(delta: float) -> void:
	var mouse_pos:Vector2 = get_global_mouse_position()
	global_position = mouse_pos


func change_tooltip(new_tooltip:String) -> void:
	label.text = new_tooltip
	if modulate.a == 0.0:
		fade_tween.remove_all()
		_fade_enter()


func hide_tooltip(tooltip:String) -> void:
	if label.text == tooltip && modulate.a > 0.0:
		fade_tween.remove_all()
		_fade_exit()


func _fade_enter() -> void:
	fade_tween.interpolate_property(
		self, "modulate:a", 0.0, 1.0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	fade_tween.start()


func _fade_exit() -> void:
	fade_tween.interpolate_property(
		self, "modulate:a", 1.0, 0.0, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	fade_tween.start()
