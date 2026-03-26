extends Resource
class_name Skill

@export var skill_id: String = ""
@export var skill_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""

var level: int = 1
var max_level: int = 1
var degradation: int = 0
var cooldown_time: float = 0.0
var current_cooldown: float = 0.0
var can_use: bool = true
var base_value: float = 1.0
var value_per_level: float = 0.5

func _init():
	max_level = 3

func get_current_value() -> float:
	return base_value + (level - 1) * value_per_level

func use() -> bool:
	if not can_use:
		return false
	can_use = false
	current_cooldown = cooldown_time
	_apply_effect()
	return true

func _apply_effect() -> void:
	pass

func upgrade() -> void:
	if level < max_level:
		level += 1

func degrade() -> void:
	degradation += 1
	if degradation >= 3:
		can_use = false

func repair() -> void:
	degradation = 0
	can_use = true

func get_degradation_name() -> String:
	match degradation:
		0: return ""
		1: return "[DEGRADED]"
		2: return "[CRITICAL]"
		3: return "[CORRUPTED]"
	return ""
