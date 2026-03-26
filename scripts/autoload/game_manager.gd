extends Node

var token: int = 0
var loop_count: int = 0
var highest_loop: int = 0
var death_count: int = 0

# 保存路径
var save_path: String = "user://savegame.ini"

signal token_changed(new_amount: int)
signal game_reset()
signal death_occurred()

func _ready() -> void:
	load_game()

func add_token(amount: int) -> void:
	token += amount
	token_changed.emit(token)
	save_game()

func remove_token(amount: int) -> bool:
	if token >= amount:
		token -= amount
		token_changed.emit(token)
		save_game()
		return true
	return false

func reset_token() -> void:
	token = 0
	token_changed.emit(token)

func increment_loop() -> void:
	loop_count += 1
	if loop_count > highest_loop:
		highest_loop = loop_count
	save_game()

func player_died() -> void:
	death_count += 1
	death_occurred.emit()

	# 技能降级
	SkillManager.degrade_all_skills()

	# 记录死亡后保留的token
	save_game()

func start_new_run() -> void:
	# 开始新一轮，保留token但清空装备
	loop_count += 1
	if loop_count > highest_loop:
		highest_loop = loop_count

	# 卸下所有装备的技能（返回仓库）
	SkillManager.equipped_skills = [null, null, null, null]

	game_reset.emit()
	save_game()

# ============ 存档系统 ============

func save_game() -> void:
	var config = ConfigFile.new()

	# 主存档数据
	config.set_value("game", "token", token)
	config.set_value("game", "loop_count", loop_count)
	config.set_value("game", "highest_loop", highest_loop)
	config.set_value("game", "death_count", death_count)

	# 拥有技能
	var owned_array: Array = []
	for skill in SkillManager.owned_skills:
		if skill != null and typeof(skill) == TYPE_DICTIONARY:
			owned_array.append(skill)
	config.set_value("skills", "owned", owned_array)

	# 装备技能（带降级状态）
	var equipped_array: Array = []
	for skill in SkillManager.equipped_skills:
		if skill != null and typeof(skill) == TYPE_DICTIONARY:
			equipped_array.append(skill)
	config.set_value("skills", "equipped", equipped_array)

	var err = config.save(save_path)
	if err != OK:
		print("保存失败: ", err)
	else:
		print("游戏已保存 | Token: ", token, " | Loop: ", loop_count)

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(save_path)

	if err != OK:
		print("没有找到存档，开始新游戏")
		return

	# 读取主存档
	token = config.get_value("game", "token", 0)
	loop_count = config.get_value("game", "loop_count", 0)
	highest_loop = config.get_value("game", "highest_loop", 0)
	death_count = config.get_value("game", "death_count", 0)

	# 读取拥有技能
	var owned_data: Array = config.get_value("skills", "owned", [])
	SkillManager.owned_skills.clear()
	for skill_data in owned_data:
		if typeof(skill_data) == TYPE_DICTIONARY:
			SkillManager.owned_skills.append(skill_data)

	# 读取装备技能
	var equipped_data: Array = config.get_value("skills", "equipped", [])
	SkillManager.equipped_skills.clear()
	for i in range(4):
		if i < equipped_data.size():
			var skill_data = equipped_data[i]
			if typeof(skill_data) == TYPE_DICTIONARY:
				SkillManager.equipped_skills.append(skill_data)
			else:
				SkillManager.equipped_skills.append(null)
		else:
			SkillManager.equipped_skills.append(null)

	print("存档已加载 | Token: ", token, " | Loop: ", loop_count, " | 技能: ", SkillManager.owned_skills.size())

func get_stats() -> Dictionary:
	return {
		"token": token,
		"loop_count": loop_count,
		"highest_loop": highest_loop,
		"death_count": death_count,
		"owned_skills": SkillManager.owned_skills.size(),
		"equipped_skills": SkillManager.equipped_skills.count(null) == 4 ? 0 : 4 - SkillManager.equipped_skills.count(null)
	}
