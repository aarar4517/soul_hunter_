extends CharacterBody2D

const SPEED = 1000.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var walk_sfx = $AudioStreamPlayer2D  # تأكد من إضافة عقدة AudioStreamPlayer2D كطفل

var is_moving = false
var was_moving = false
var can_move = true  # متغير للتحكم في إمكانية الحركة

func _ready() -> void:
	add_to_group("player")
	if animated_sprite:
		animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	# إذا كان اللاعب لا يمكنه الحركة (مثل بعد الفوز)، توقف هنا
	if not can_move:
		velocity = Vector2.ZERO
		return
	
	# التحكم في الحركة في جميع الاتجاهات
	var movement = Vector2.ZERO
	
	# قراءة مدخلات الحركة
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if Input.is_action_pressed("ui_up"):
		movement.y -= 1
	
	# تحديث حالة الحركة
	was_moving = is_moving
	is_moving = movement.length() > 0
	
	# التحكم في صوت المشي
	_handle_walk_sfx()
	
	# تطبيق الحركة إذا كان هناك مدخلات
	if movement.length() > 0:
		movement = movement.normalized()
		velocity = movement * SPEED
	else:
		velocity = Vector2.ZERO
	
	# تطبيق الحركة
	move_and_slide()
	
	# تحديث الأنيميشن
	_update_animation(movement)

func _handle_walk_sfx():
	if walk_sfx:
		if is_moving and not was_moving:
			# بدء الحركة - تشغيل الصوت
			if not walk_sfx.playing:
				walk_sfx.play()
		elif not is_moving and was_moving:
			# توقف الحركة - إيقاف الصوت
			walk_sfx.stop()

func _update_animation(direction: Vector2) -> void:
	if animated_sprite == null:
		return
		
	if direction.length() > 0:
		if abs(direction.x) > abs(direction.y):
			# الحركة الأفقية هي السائدة
			if direction.x > 0:
				animated_sprite.play("walk_right")
				animated_sprite.flip_h = false
			else:
				animated_sprite.play("walk_left")
				animated_sprite.flip_h = true
		else:
			# الحركة العمودية هي السائدة
			if direction.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
	else:
		animated_sprite.play("idle")

# دالة جديدة للفوز
func win_game():
	print("🎉 اللاعب فاز!")
	can_move = false  # منع الحركة
	velocity = Vector2.ZERO  # إيقاف الحركة
	
	# إيقاف صوت المشي إذا كان يعمل
	if walk_sfx and walk_sfx.playing:
		walk_sfx.stop()
	
	# تشغيل أنيميشن الفوز إذا موجود
	if animated_sprite and animated_sprite.has_animation("win"):
		animated_sprite.play("win")
	elif animated_sprite:
		animated_sprite.play("idle")  # أو أي أنيميشن مناسبة
	
	# إرسال إشارة الفوز
	get_tree().call_group("game_manager", "on_player_win")
