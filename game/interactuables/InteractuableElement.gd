tool
extends Node2D

signal activated()

onready var body:Sprite = $Body
onready var outline_tween: Tween = $OutlineTween
onready var interact_area: Area2D = $InteractArea
onready var interact_area_col:CollisionShape2D = $InteractArea/CollisionShape2D
onready var interact_sfx:AudioHandler = $InteractSFX

export (bool) var starts_hidden:bool = false

export (Texture) var texture:Texture setget set_texture
export (Color) var outline_color:Color = Color.white
export (Shape2D) var interact_area_shape:Shape2D setget set_interact_area_shape
export (String) var tooltip:String
export (PoolStringArray) var dialogue:PoolStringArray
export (float) var dialogue_speed:float = 0.05
export (Array, Texture) var inspect_textures:Array

export (AudioStream) var interaction_audio:AudioStream
export (float) var interaction_audio_db:float

export (String) var progress_key_unlock:String
export (bool) var key_oneshot:bool = true
export (String) var hide_on_key:String
export (String) var show_on_key:String

var in_range:bool = false
var mouse_in:bool = false


func set_texture(text:Texture) -> void:
	texture = text
	if has_node("Body"):
		$Body.texture = text


func set_interact_area_shape(new_shape:Shape2D) -> void:
	interact_area_shape = new_shape
	if has_node("InteractArea/CollisionShape2D"):
		$InteractArea/CollisionShape2D.shape = new_shape


func _ready() -> void:
	interact_area_col.shape = interact_area_shape
	body.texture = texture
	if !Engine.editor_hint:
		interact_area.connect("mouse_entered", self, "_on_InteractArea_mouse_entered")
		interact_area.connect("mouse_exited", self, "_on_InteractArea_mouse_exited")
		outline_color.a = 0
		body.use_parent_material = true
		body.material = body.material.duplicate()
		visible = !starts_hidden
		if interaction_audio != null:
			interact_sfx._audio_references = [interaction_audio]
			interact_sfx._db_volumes = [interaction_audio_db]


func _on_InteractArea_mouse_entered() -> void:
	mouse_in = true
	if in_range:
		_interpolate_interact_enter()
		_show_tooltip()


func _on_InteractArea_mouse_exited() -> void:
	mouse_in = false
	if in_range:
		_interpolate_interact_exit()
		_hide_tooltip()


func _interpolate_interact_enter() -> void:
	outline_tween.interpolate_method(
		self, "outline_alpha", outline_color.a, 1.0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	outline_tween.start()


func _interpolate_interact_exit() -> void:
	outline_tween.interpolate_method(
		self, "outline_alpha", outline_color.a, 0.0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	outline_tween.start()


func outline_alpha(value: float) -> void:
	outline_color.a = value
	body.material.set_shader_param("line_color", outline_color)


func _show_tooltip() -> void:
	get_tree().call_group("tooltip", "change_tooltip", tooltip)


func _hide_tooltip() -> void:
	get_tree().call_group("tooltip", "hide_tooltip", tooltip)


func _on_InteractArea_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		in_range = true
		if mouse_in:
			_interpolate_interact_enter()
			_show_tooltip()


func _on_InteractArea_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_area"):
		in_range = false
		outline_tween.reset_all()
		_interpolate_interact_exit()
		_hide_tooltip()


func _on_InteractArea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if !dialogue.empty() && event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_pressed():
		get_tree().call_group("event_synchronizer", "queue_action", funcref(self, "handle_interaction"), get_global_mouse_position())


func notify_key_progress_unlocked(key_progress:String) -> void:
	match key_progress:
		hide_on_key:
			hide()
		show_on_key:
			show()


func handle_interaction(player:Node2D) -> void:
	var space_state:Physics2DDirectSpaceState = get_world_2d().direct_space_state
	var result:Dictionary = space_state.intersect_ray(global_position, player.global_position)
	if result.empty():
		var tree:SceneTree = get_tree()
		tree.call_group("dialogue", "show_dialogue", dialogue, dialogue_speed)
		if !inspect_textures.empty():
			tree.call_group("inspector", "show_inspector", inspect_textures)
		
		interact_sfx.play()
		
		var key:String = "action" if progress_key_unlock.empty() else progress_key_unlock
		tree.call_group("progress_listeners", "notify_key_progress_unlocked", key)
		if key_oneshot && key != "action":
			progress_key_unlock = ""
		
		emit_signal("activated")
