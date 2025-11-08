extends AudioStreamPlayer2D

@onready var player = get_parent()  # افترض أن هذا العقدة تابعة للاعب

var was_moving = false
var is_enabled = true

func _ready() -> void:
	# تعطيل معالجة الإدخال لهذا المشغل الصوتي
	set_process_input(false)
	
	# ضبط إعدادات الصوت لتجنب التداخل
	volume_db = -5.0  # مستوى صوت معتدل
	bus = "SFX"  # استخدام bus مخصص لأصوات المؤثرات (المشي)

func _process(delta: float) -> void:
	if not is_enabled:
		return
		
	if player and player.has_method("is_moving"):
		var is_moving_now = player.is_moving
		
		# إذا بدأ اللاعب الحركة الآن ولم يكن يتحرك سابقاً
		if is_moving_now and not was_moving:
			if not playing:
				play()
		
		# إذا توقف اللاعب عن الحركة الآن وكان يتحرك سابقاً
		elif not is_moving_now and was_moving:
			if playing:
				stop()
		
		# تحديث حالة الحركة السابقة
		was_moving = is_moving_now

# دوال للتحكم في تشغيل وإيقاف صوت المشي من الخارج
func enable_walk_sfx():
	is_enabled = true

func disable_walk_sfx():
	is_enabled = false
	if playing:
		stop()
