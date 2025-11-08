extends Control
 
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options


# Called when the node enters the scene tree for the first time.
func _ready():
	main_buttons.visible = true
	options.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_Start_pressed():
	get_tree().change_scene_to_file("res://Map assets/game.tscn")
	
func _on_Settings_pressed():
	print("Settings pressed")
	main_buttons.visible = false
	options.visible = true

func _on_Exit_pressed():
	get_tree().quit()





func _on_back_options_pressed() -> void:
	_ready()
