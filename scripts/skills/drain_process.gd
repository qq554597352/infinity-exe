extends Skill
class_name DrainProcess

# drain_process.exe - 算力汲取
# 击杀敌人后额外获得Token

var token_bonus_percent: float = 50.0
var duration: float = 10.0
var is_active: bool = false

func _init():
	skill_id = "drain_process"
	skill_name = "drain_process.exe"
	description = "击杀敌人后额外获得Token"
	cooldown_time = 15.0
	base_value = 50.0
	max_level = 3

func _apply_effect() -> void:
	is_active = true

func get_description() -> String:
	return "Token加成: %.0f%%  持续: %.1fs" % [token_bonus_percent, duration]

func get_token_bonus(base_token: int) -> int:
	if is_active:
		return int(base_token * (token_bonus_percent / 100.0))
	return 0

func deactivate() -> void:
	is_active = false
