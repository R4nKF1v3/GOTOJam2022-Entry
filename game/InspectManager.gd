extends Control

onready var scroll_buttons:Array = [$ScrollLeft, $ScrollRight]
onready var preview:TextureRect = $InspectPreview

var textures:Array = []
var index:int = 0


func _ready() -> void:
	hide()


func show_inspector(inspection_textures:Array) -> void:
	show()
	index = 0
	textures = inspection_textures
	preview.texture = textures[0]
	var show_buttons:bool = textures.size() > 1
	for button in scroll_buttons:
		button.visible = show_buttons


func _on_ScrollLeft_button_up() -> void:
	index = ((index * int(index > 0) + textures.size() * int(index == 0)) - 1) % textures.size()
	preview.texture = textures[index]


func _on_ScrollRight_button_up() -> void:
	index = (index + 1) % textures.size()
	preview.texture = textures[index]


func _on_ReturnButton_button_up() -> void:
	hide()
