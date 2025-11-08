extends CharacterBody2D

@export var speed: float = 350.0
@export var detection_range: float = 3000.0
@export var wander_speed: float = 200.0

var target = null
var wander_timer: float = 0.0
var wander_target_position: Vector2 = Vector2.ZERO
var is_wandering_to_point: bool = false

func _ready():
	find_player()
	start_wandering_in_map()

func _physics_process(delta: float) -> void:
	# البحث عن اللاعب إذا لم يكن هناك هدف
	if not target:
		find_player()
	
	# إذا كان اللاعب في نطاق المطاردة
	if target and is_instance_valid(target):
		var distance_to_player = global_position.distance_to(target.global_position)
		
		if distance_to_player <= detection_range:
			# مطاردة اللاعب مباشرة
			chase_player(delta)
		else:
			# حركة عشوائية في الماب كامل
			wander_in_map(delta)
	else:
		# حركة عشوائية إذا لم يوجد لاعب
		wander_in_map(delta)
		find_player()
	
	move_and_slide()

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func chase_player(_delta):
	if not is_instance_valid(target):
		return
	
	# التحرك مباشرة نحو اللاعب بدون انحراف
	var direction = (target.global_position - global_position).normalized()
	
	# تطبيق السرعة مباشرة نحو اللاعب
	velocity = direction * speed
	
	# منع البوت من الخروج من حدود الكاميرا
	clamp_to_camera_bounds()

func wander_in_map(delta):
	wander_timer -= delta
	
	if wander_timer <= 0 or not is_wandering_to_point:
		start_wandering_in_map()
	
	if is_wandering_to_point:
		var direction = (wander_target_position - global_position).normalized()
		velocity = direction * wander_speed
		
		# إذا وصل لنقطة التجوال أو كان قريباً منها، ابدأ تجوالاً جديداً
		if global_position.distance_to(wander_target_position) < 50:
			start_wandering_in_map()
	
	# منع البوت من الخروج من حدود الكاميرا أثناء التجوال
	clamp_to_camera_bounds()

func start_wandering_in_map():
	var map_bounds = get_map_bounds()
	
	wander_target_position = Vector2(
		randf_range(map_bounds[0].x, map_bounds[1].x),
		randf_range(map_bounds[0].y, map_bounds[1].y)
	)
	
	is_wandering_to_point = true
	wander_timer = randf_range(3.0, 8.0)

func get_map_bounds():
	var camera = get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport().get_visible_rect().size
		var camera_center = camera.global_position
		return [
			camera_center - viewport_size / 2,
			camera_center + viewport_size / 2
		]
	
	return [Vector2(-1000, -1000), Vector2(1000, 1000)]

func clamp_to_camera_bounds():
	var bounds = get_map_bounds()
	global_position.x = clamp(global_position.x, bounds[0].x, bounds[1].x)
	global_position.y = clamp(global_position.y, bounds[0].y, bounds[1].y)

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		game_over()

func game_over():
	print("انتهت اللعبة! لقد خسرت!")
	
	# إيقاف حركة اللاعب
	if target and is_instance_valid(target):
		target.velocity = Vector2.ZERO
		target.set_physics_process(false)
	
	# إظهار رسالة الخسارة
	get_tree().call_group("ui", "show_game_over")
	
	# إيقاف اللعبة بعد ثانيتين
	await get_tree().create_timer(2.0).timeout
	
	# إعادة تحميل المشهد أو الانتقال للقائمة الرئيسية
	get_tree().change_scene_to_file("res://menus/game_over.tscn")

func _on_area_2d_body_entered(body):
	# عندما يلمس العدو اللاعب
	if body.is_in_group("player"):
		game_over()
		
