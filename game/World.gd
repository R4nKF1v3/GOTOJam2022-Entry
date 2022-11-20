extends Node

onready var player:Player = $Player
onready var old_scenario:Scenario = $OldScenario
onready var young_scenario:Scenario = $YoungScenario

var current_scenario:Scenario


func _ready() -> void:
	_change_current_scenario(old_scenario)


func _change_current_scenario(scenario:Scenario) -> void:
	if current_scenario != null:
		player.global_position -= current_scenario.global_position
	current_scenario = scenario
	player.global_position += current_scenario.global_position
	current_scenario.set_as_current(player)


func _on_ChangeStateButton_button_up() -> void:
	_change_current_scenario(old_scenario if current_scenario == young_scenario else young_scenario)
