extends Node

onready var player:Player = $Player
onready var old_scenario:Scenario = $OldScenario
onready var young_scenario:Scenario = $YoungScenario

var current_scenario:Scenario

var queued_callback:FuncRef
var callback_point:Vector2

var keys_unlocked:Array = []


func _ready() -> void:
	old_scenario.setup()
	young_scenario.setup()
	_change_current_scenario(old_scenario)


func _change_current_scenario(scenario:Scenario) -> void:
	if current_scenario != null:
		player.global_position -= current_scenario.global_position
	current_scenario = scenario
	player.global_position += current_scenario.global_position
	current_scenario.set_as_current(player)


func _on_ChangeStateButton_button_up() -> void:
	_change_current_scenario(old_scenario if current_scenario == young_scenario else young_scenario)


func queue_action(callback:FuncRef, point:Vector2) -> void:
	if !player.moving:
		callback.call_func(player)
		queued_callback = null
	else:
		queued_callback = callback
		callback_point = point


func _on_Player_changed_target(target:Vector2) -> void:
	if target != callback_point:
		queued_callback = null


func _on_Player_stopped_moving() -> void:
	if queued_callback:
		queued_callback.call_func(player)
		queued_callback = null


func notify_key_progress_unlocked(key_progress:String) -> void:
	keys_unlocked.push_back(key_progress)
