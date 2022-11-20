extends Node
class_name Screen

signal change_screen(value)

var active = false


func enter(_value)->void:
	_play_enter_animation()


func exit()->void:
	active = false
	_play_exit_animation()


func _change_screen(screen_id, value = null)->void:
	if active:
		emit_signal("change_screen", screen_id, value)


#interfaces for child implementation
func previous()->void:
	pass


func _play_enter_animation()->void:
	pass


func _play_exit_animation()->void:
	pass

