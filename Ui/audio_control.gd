extends HSlider

@export var audio_bus_name: String = "Master"
var audio_bus_id: int

func _ready():
	# الحصول على ID الباص الصوتي
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	# التحقق من وجود الباص الصوتي
	if audio_bus_id == -1:
		push_error("Audio bus not found: " + audio_bus_name)
		return
	
	# تعيين القيمة الابتدائية حسب الصوت الحالي
	var current_volume_db = AudioServer.get_bus_volume_db(audio_bus_id)
	value = db_to_linear(current_volume_db)
	
	# ربط إشارة تغيير القيمة
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
	if audio_bus_id == -1:
		return
	
	# تحويل القيمة الخطية إلى ديسيبل
	var db_volume = linear_to_db(new_value)
	
	# تعيين مستوى الصوت
	AudioServer.set_bus_volume_db(audio_bus_id, db_volume)
	
	# طباعة مستوى الصوت الحالي (اختياري)
	print("Volume for bus '", audio_bus_name, "': ", db_volume, " dB")

# دالة مساعدة للحصول على مستوى الصوت الحالي
func get_current_volume_db() -> float:
	if audio_bus_id != -1:
		return AudioServer.get_bus_volume_db(audio_bus_id)
	return 0.0

# دالة مساعدة لتعيين الصوت مباشرة بقيمة ديسيبل
func set_volume_db(db_value: float) -> void:
	if audio_bus_id != -1:
		var clamped_db = clamp(db_value, -80.0, 6.0)  # نطاق صوت معقول
		AudioServer.set_bus_volume_db(audio_bus_id, clamped_db)
		value = db_to_linear(clamped_db)
