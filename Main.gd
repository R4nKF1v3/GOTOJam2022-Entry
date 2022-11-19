extends Node

var screens_map = {}
var current_screen = null


func _ready()->void:
	randomize()
	get_tree().set_auto_accept_quit(false)
	OS.set_window_position(Vector2())
	
	screens_map = {
		GameState.SCREENS.LOADING: $LoadingScreen,
		GameState.SCREENS.MENU: $MainMenuScreen,
		GameState.SCREENS.GAME: $GameScreen
	}
	
	for s in screens_map.values():
		s.connect("change_screen", self, "_on_change_screen")
	call_deferred("_change_screen", GameState.SCREENS.LOADING, null)


func _change_screen(screen_id, value):
	if current_screen:
		current_screen.exit()
	current_screen = screens_map[screen_id]
	current_screen.enter(value)


func _on_change_screen(screen_id, value = null):
	call_deferred("_change_screen", screen_id, value)
