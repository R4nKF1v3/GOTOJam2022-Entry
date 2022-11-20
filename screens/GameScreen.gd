extends Screen

export (PackedScene) var game_scene:PackedScene

var game


func enter(value) -> void:
	if is_instance_valid(game):
		if is_a_parent_of(game):
			remove_child(game)
		game.queue_free()
	
	game = game_scene.instance()
#	game.connect("game_cleared", self, "_on_game_cleared")
#	game.connect("quit_requested", self, "_on_quit_requested")
	add_child(game)
#	game.setup()
	active = true
	.enter(value)


func exit() -> void:
#	game.notify_exit()
	yield(get_tree().create_timer(1.0), "timeout")
	if is_a_parent_of(game):
		remove_child(game)
	game.queue_free()
	get_tree().paused = false


func previous()->void:
	return


func _on_game_cleared() -> void:
	_change_screen(GameState.SCREENS.LOADING, GameState.SCREENS.MENU)


func _on_quit_requested(screen:int = GameState.SCREENS.MENU) -> void:
	_change_screen(GameState.SCREENS.LOADING, screen)
