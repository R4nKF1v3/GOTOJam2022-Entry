extends TextureButton

signal number_selected(number)

export (int) var number
export (Color) var outline_color:Color = Color.red

var outline_tween:Tween = Tween.new()

var locked:bool = false


func _ready() -> void:
	add_child(outline_tween)
	connect("mouse_entered", self, "_interpolate_interact_enter")
	connect("mouse_exited", self, "_interpolate_interact_exit")
	connect("button_up", self, "_on_button_up")
	material = material.duplicate()
	outline_alpha(0.0)


func _interpolate_interact_enter() -> void:
	if !locked:
		outline_tween.interpolate_method(
			self, "outline_alpha", outline_color.a, 1.0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT
		)
		outline_tween.start()


func _interpolate_interact_exit() -> void:
	if !locked:
		outline_tween.interpolate_method(
			self, "outline_alpha", outline_color.a, 0.0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		outline_tween.start()


func outline_alpha(value: float) -> void:
	outline_color.a = value
	material.set_shader_param("line_color", outline_color)


func _on_button_up() -> void:
	lock()
	emit_signal("number_selected", number)


func reset() -> void:
	locked = false
	outline_alpha(0.0)


func lock() -> void:
	locked = true
	outline_tween.remove_all()
	outline_alpha(1.0)
