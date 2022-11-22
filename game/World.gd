extends Node

signal game_cleared()

onready var player:Player = $Player
onready var old_scenario:Scenario = $OldScenario
onready var young_scenario:Scenario = $YoungScenario

onready var input_block:Control = $Interface/InputBlock
onready var in_out_anim:AnimationPlayer = $IntroOutroAnim
onready var switch_sfx:AudioStreamPlayer = $SwitchSFX
onready var vignette_tween:Tween = $VignetteTween
onready var vignette:CanvasItem = $Overlay/ScreenEffects/VignetteEffect
onready var background:ColorRect = $BackgroundLayer/Background

export (Color) var young_background_color:Color
export (Color) var old_background_color:Color

export (PoolStringArray) var initial_dialogue:PoolStringArray
export (PoolStringArray) var final_dialogue:PoolStringArray

var current_scenario:Scenario

var queued_callback:FuncRef
var callback_point:Vector2

var keys_unlocked:Array = []


func setup() -> void:
	randomize()
	old_scenario.setup()
	young_scenario.setup()
	_change_current_scenario(old_scenario)
	input_block.show()
	get_tree().call_group("dialogue", "show_dialogue", initial_dialogue)
	in_out_anim.play("intro")


func _change_current_scenario(scenario:Scenario) -> void:
	if current_scenario != null:
		player.global_position -= current_scenario.global_position
	current_scenario = scenario
	player.global_position += current_scenario.global_position
	current_scenario.set_as_current(player)


func _on_ChangeStateButton_toggled(button_pressed: bool) -> void:
	input_block.show()
	player.current_path = PoolVector2Array()
	player.target = player.global_position
	vignette_tween.interpolate_method(self, "_change_vignette", 0.4, 16.0, 4.9)
	vignette_tween.interpolate_method(self, "_change_vignette", 16.0, 0.4, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 4.9)
	var color_selected:Color = young_background_color if button_pressed else old_background_color
	vignette_tween.interpolate_property(background, "color", background.color, color_selected, 0.1, 0, 2, 4.9)
	vignette_tween.start()
	switch_sfx.play()
	yield(vignette_tween, "tween_all_completed")
	_change_current_scenario(young_scenario if button_pressed else old_scenario)
	player.toggle_state(button_pressed)
	input_block.hide()


func _change_vignette(intensity:float) -> void:
	vignette.material.set_shader_param("vignette_intensity", intensity)


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
	if !keys_unlocked.has(key_progress):
		keys_unlocked.push_back(key_progress)


func _on_StrongboxInspector_strongbox_opened() -> void:
	get_tree().call_group("dialogue", "show_dialogue", final_dialogue)
	in_out_anim.play("outro")
	vignette_tween.interpolate_method(self, "_change_vignette", 0.4, 16.0, 0.5)
	vignette_tween.interpolate_method(self, "_change_vignette", 16.0, 0.4, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	vignette_tween.start()


func finish() -> void:
	emit_signal("game_cleared")
