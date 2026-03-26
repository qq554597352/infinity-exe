extends Node

# 技能管理器

var skill_pool: Array = []
var owned_skills: Array = []
var equipped_skills: Array = [null, null, null, null]
var max_owned: int = 10
var max_equipped: int = 4

signal skill_acquired(skill_data: Dictionary)
signal skill_equipped(slot: int, skill_data: Dictionary)
signal skill_used(skill_id: String)

func _ready() -> void:
	_init_skill_pool()

func _init_skill_pool() -> void:
	skill_pool.append(load("res://scripts/skills/dash_strike.gd").new())
	skill_pool.append(load("res://scripts/skills/bullet_bloom.gd").new())
	skill_pool.append(load("res://scripts/skills/drain_process.gd").new())
	skill_pool.append(load("res://scripts/skills/evasion_protocol.gd").new())

func generate_skill_fragment() -> Dictionary:
	if skill_pool.is_empty():
		return {}
	if owned_skills.size() >= max_owned:
		return {}

	var random_index: int = randi() % skill_pool.size()
	var skill = skill_pool[random_index]
	var fragment: Dictionary = {
		"id": skill.skill_id,
		"name": skill.skill_name,
		"description": skill.description,
		"level": 1,
		"degradation": 0
	}

	owned_skills.append(fragment)
	skill_acquired.emit(fragment)
	return fragment

func get_owned_skills() -> Array:
	return owned_skills

func equip_skill(slot: int, skill_data: Dictionary) -> bool:
	if slot < 0 or slot >= max_equipped:
		return false

	equipped_skills[slot] = skill_data
	skill_equipped.emit(slot, skill_data)

	var idx: int = owned_skills.find(skill_data)
	if idx >= 0:
		owned_skills.remove_at(idx)

	return true

func unequip_skill(slot: int) -> Dictionary:
	if slot < 0 or slot >= max_equipped:
		return {}

	var skill_data = equipped_skills[slot]
	if skill_data == null or typeof(skill_data) != TYPE_DICTIONARY:
		return {}

	if owned_skills.size() < max_owned:
		owned_skills.append(skill_data)

	equipped_skills[slot] = null
	return skill_data

func use_skill(slot: int) -> bool:
	if slot < 0 or slot >= max_equipped:
		return false

	var skill_data = equipped_skills[slot]
	if skill_data == null or typeof(skill_data) != TYPE_DICTIONARY:
		return false

	var skill_id: String = ""
	if "id" in skill_data:
		skill_id = str(skill_data["id"])
	skill_used.emit(skill_id)
	return true

func get_equipped_skills() -> Array:
	return equipped_skills

func degrade_all_skills() -> void:
	for i in range(equipped_skills.size()):
		var skill = equipped_skills[i]
		if skill != null and typeof(skill) == TYPE_DICTIONARY:
			var deg: int = 0
			if "degradation" in skill:
				deg = int(skill["degradation"])
			equipped_skills[i]["degradation"] = deg + 1

func repair_skill(slot: int) -> bool:
	if slot < 0 or slot >= max_equipped:
		return false

	var skill = equipped_skills[slot]
	if skill != null and typeof(skill) == TYPE_DICTIONARY:
		equipped_skills[slot]["degradation"] = 0
		return true
	return false
