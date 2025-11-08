extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Win")
		win_game()

func win_game():
	# إيقاف حركة اللاعب
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
	
	# إظهار رسالة الفوز البسيطة
	show_simple_win_message()

	await get_tree().create_timer(2.0).timeout
	
	if ResourceLoader.exists("res://menus/victory_screen.tscn"):
		get_tree().change_scene_to_file("res://menus/victory_screen.tscn")
	else:
		print("تحذير: مشهد الفوز غير موجود")
		get_tree().reload_current_scene()

func show_simple_win_message():
	# رسالة فوز بسيطة
	var win_label = Label.new()
	win_label.text = "YOU WIN!"
	win_label.add_theme_font_size_override("font_size", 72)
	win_label.position = Vector2(200, 300)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(win_label)
	get_tree().root.add_child(canvas_layer)
