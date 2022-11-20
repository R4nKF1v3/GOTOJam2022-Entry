extends Screen

onready var container:Control = $Container


func _ready() -> void:
	container.visible = active


func _play_enter_animation()->void:
	active = true
	container.show()


func _play_exit_animation()->void:
	container.hide()


func _on_StartButton_button_up() -> void:
	_change_screen(GameState.SCREENS.LOADING, GameState.SCREENS.GAME)


func _on_ExitButton_button_up() -> void:
	get_tree().quit()
