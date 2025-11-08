extends CharacterBody2D

@export var speed: float = 500.0
@export var damage: int = 50
@export var detection_range: float = 2500.0
@export var wander_speed: float = 300.0

var target = null
var player_in_range = false
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var wander_interval: float = 2.0
var wander_target_position: Vector2 = Vector2.ZERO
var is_wandering_to_point: bool = false

# الجاذبية


func _ready():
	find_player()
	# بدء الحركة العشوائية في الماب كامل
	start_wandering_in_map()

func _physics_process(delta: float) -> void:
	# تطبيق الجاذبية
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# البحث عن اللاعب إذا لم يكن هناك هدف
	if not target:
		find_player()
	
	# إذا كان اللاعب في نطاق المطاردة
	if target and is_instance_valid(target):
		var distance_to_player = global_position.distance_to(target.global_position)
		
		if distance_to_player <= detection_range:
			# مطاردة اللاعب
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

func chase_player(delta):
	if not is_instance_valid(target):
		return
	
	var direction = (target.global_position - global_position).normalized()
	
	# التحرك نحو اللاعب
	velocity.x = direction.x * speed
	
	# القفز إذا كان اللاعب أعلى وكان البوت على الأرض
	if target.global_position.y < global_position.y - 50 and is_on_floor():
		velocity.y = -300

func wander_in_map(delta):
	wander_timer -= delta
	
	if wander_timer <= 0 or not is_wandering_to_point:
		# اختيار نقطة عشوائية جديدة في الماب
		start_wandering_in_map()
	
	if is_wandering_to_point:
		# التحرك نحو النقطة العشوائية
		var direction = (wander_target_position - global_position).normalized()
		velocity.x = direction.x * wander_speed
		
		# إذا وصلنا قريباً من النقطة، نختار نقطة جديدة
		if global_position.distance_to(wander_target_position) < 50:
			start_wandering_in_map()
	
	# قفز عشوائي أحياناً
	if is_on_floor() and randf() < 0.01:
		velocity.y = -200

func start_wandering_in_map():
	# الحصول على حدود الماب أو استخدام حدود افتراضية
	var map_bounds = get_map_bounds()
	
	# توليد موقع عشوائي ضمن حدود الماب
	wander_target_position = Vector2(
		randf_range(map_bounds[0].x, map_bounds[1].x),
		randf_range(map_bounds[0].y, map_bounds[1].y)
	)
	
	is_wandering_to_point = true
	wander_timer = randf_range(3.0, 8.0)  # وقت أطول للتجول في الماب الكبير
	
	print("البوت يتجه إلى موقع عشوائي: ", wander_target_position)

func get_map_bounds():
	# طريقة 1: إذا كان لديك حدود محددة للماب
	# return [Vector2(0, 0), Vector2(5000, 3000)]  # غير القيم حسب حجم مابك
	
	# طريقة 2: البحث عن حدود الماب تلقائياً
	var camera = get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport().get_visible_rect().size
		var camera_center = camera.global_position
		return [
			camera_center - viewport_size * 2,  # توسيع الحدود
			camera_center + viewport_size * 2
		]
	
	# طريقة 3: استخدام حدود افتراضية كبيرة
	return [Vector2(-5000, -5000), Vector2(5000, 5000)]

func wander(delta):
	# الاحتفاظ بالدالة القديمة للتوافق
	wander_timer -= delta
	
	if wander_timer <= 0:
		start_wandering()
	
	velocity.x = wander_direction.x * wander_speed
	
	if is_on_floor() and randf() < 0.01:
		velocity.y = -200

func start_wandering():
	# الاحتفاظ بالدالة القديمة للتوافق
	wander_direction = Vector2(randf_range(-1, 1), 0).normalized()
	wander_timer = randf_range(1.0, 3.0)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		target = body
		print("تم اكتشاف اللاعب!")

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		kill_player(body)

func kill_player(player):
	if is_instance_valid(player):
		if player.has_method("take_damage"):
			player.take_damage(damage)
		elif player.has_method("die"):
			player.die()
		else:
			get_tree().reload_current_scene()
		
		print("البوت قتل اللاعب!")
		
