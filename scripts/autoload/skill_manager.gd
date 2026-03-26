extends Node

# 技能管理器
# 管理技能碎片获取、装备、使用

# 技能池（可掉落的技能）
var skill_pool: Array[Resource] = []

# 已拥有的技能碎片
var owned_skills: Array[Dictionary] = []

# 已装备的技能（最多4个）
var equipped_skills: Array = [null, null, null, null]

# 最大拥有数量
var max_owned: int = 10
var max_equipped: int = 4

signal skill_acquired(skill_data: Dictionary)
signal skill_equipped(slot: int, skill_data: Dictionary)
signal skill_used(skill_id: String)

func _ready() -> void:
	_init_skill_pool()

func _init_skill_pool() -> void:
	# 初始化技能池
	skill_pool.append(load("res://scripts/skills/dash_strike.gd").new())
	skill_pool.append(load("res://scripts/skills/bullet_bloom.gd").new())
	skill_pool.append(load("res://scripts/skills/drain_process.gd").new())
	skill_pool.append(load("res://scripts/skills/evasion_protocol.gd").new())

# 生成随机技能碎片
func generate_skill_fragment() -> Dictionary:
	if skill_pool.is_empty():
		return {}
	if owned_skills.size() >= max_owned:
		return {}

	var skill: Skill = skill_pool[randi() % skill_pool.size()]
	var fragment := {
		"id": skill.skill_id,
		"name": skill.skill_name,
		"description": skill.description,
		"level": 1,
		"degradation": 0
	}

	owned_skills.append(fragment)
	skill_acquired.emit(fragment)
	return fragment

# 获取已拥有的技能
func get_owned_skills() -> Array:
	return owned_skills

# 装备技能到槽位
func equip_skill(slot: int, skill_data: Dictionary) -> bool:
	if slot < 0 or slot >= max_equipped:
		return false

	equipped_skills[slot] = skill_data
	skill_equipped.emit(slot, skill_data)

	# 从拥有列表移除
	var idx := owned_skills.find(skill_data)
	if idx >= 0:
		owned_skills.remove_at(idx)

	return true

# 卸下装备
func unequip_skill(slot: int) -> Dictionary:
	if slot < 0 or slot >= max_equipped:
		return {}

	var skill_data: Dictionary = equipped_skills[slot]
	if skill_data.is_empty():
		return {}

	# 如果拥有列表未满，放回
	if owned_skills.size() < max_owned:
		owned_skills.append(skill_data)

	equipped_skills[slot] = null
	return skill_data

# 使用技能
func use_skill(slot: int) -> bool:
	if slot < 0 or slot >= max_equipped:
		return false

	var skill_data: Dictionary = equipped_skills[slot]
	if skill_data.is_empty():
		return false

	skill_used.emit(skill_data.get("id", ""))
	return true

# 获取装备的技能
func get_equipped_skills() -> Array:
	return equipped_skills

# 降级所有技能
func degrade_all_skills() -> void:
	for i in range(equipped_skills.size()):
		if equipped_skills[i]:
			var deg: int = equipped_skills[i].get("degradation", 0)
			equipped_skills[i]["degradation"] = deg + 1

# 修复技能
func repair_skill(slot: int) -> bool:
	if slot < 0 or slot >= max_equipped:
		return false

	if equipped_skills[slot]:
		equipped_skills[slot]["degradation"] = 0
		return true
	return false

# 获取技能效果值
func get_skill_value(skill_id: String, value_name: String) -> float:
	for skill: Skill in skill_pool:
		if skill.skill_id == skill_id:
			if value_name in skill:
				return skill.get(value_name)
	return 1.0
