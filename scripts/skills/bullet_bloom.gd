extends Skill
class_name BulletBloom

# bullet_bloom.exe - 弹幕格挡
# 释放短程爆发，摧毁弹幕并反弹

var burst_radius: float = 80.0
var projectile_count: int = 6
var destroy_projectiles: bool = true
var reflect_damage: float = 0.5

func _init():
	skill_id = "bullet_bloom"
	skill_name = "bullet_bloom.exe"
	description = "释放能量爆发，摧毁前方弹幕"
	cooldown_time = 2.0
	base_value = 80.0
	max_level = 3

func _apply_effect() -> void:
	pass

func get_description() -> String:
	return "范围: %d  反弹伤害: %.0f%%" % [burst_radius, reflect_damage * 100]
