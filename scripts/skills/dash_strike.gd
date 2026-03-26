extends Skill
class_name DashStrike

# dash_strike.exe - 冲锋斩
# 朝面前快速冲刺并造成伤害

var dash_speed: float = 800.0
var dash_distance: float = 100.0
var damage_bonus: float = 2.0
var i_frames_duration: float = 0.2

func _init():
	skill_id = "dash_strike"
	skill_name = "dash_strike.exe"
	description = "向前冲刺攻击，造成额外伤害并获得短暂无敌"
	cooldown_time = 0.8
	base_value = 100.0
	value_per_level = 50.0
	max_level = 3

func _apply_effect() -> void:
	# 效果在 PlayerController 中实现
	pass

func get_description() -> String:
	return "冲刺距离: %d  伤害: %.1f  无敌: %.1fs" % [dash_distance, damage_bonus, i_frames_duration]
