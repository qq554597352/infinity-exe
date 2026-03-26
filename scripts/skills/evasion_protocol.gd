extends Skill
class_name EvasionProtocol

# evasion_protocol.exe - 紧急闪避
# 短距离闪烁，获得延长无敌帧

var blink_distance: float = 150.0
var i_frames_extension: float = 0.5
var charges: int = 2
var current_charges: int = 2
var charge_cooldown: float = 3.0

func _init():
	skill_id = "evasion_protocol"
	skill_name = "evasion_protocol.exe"
	description = "短距离闪烁，延长无敌时间"
	cooldown_time = 0.5
	base_value = 150.0
	max_level = 3

func _apply_effect() -> void:
	pass

func get_description() -> String:
	return "闪烁距离: %d  无敌延长: %.1fs  充能: %d" % [blink_distance, i_frames_extension, charges]

func use_charge() -> bool:
	if current_charges > 0:
		current_charges -= 1
		return true
	return false

func recharge() -> void:
	if current_charges < charges:
		current_charges += 1
