extends CanvasLayer

# 技能UI - 显示底部4个技能槽位

@export var slot_size: int = 64
@export var slot_spacing: int = 10

@onready var skill_slots: Array = []
@onready var background: ColorRect = $Background

func _ready() -> void:
	_create_skill_slots()
	_update_display()

func _create_skill_slots() -> void:
	# 创建4个技能槽位
	for i in range(4):
		var slot: Panel = Panel.new()
		slot.name = "SkillSlot" + str(i)

		# 设置槽位大小和位置
		var x_pos: float = (get_viewport_rect().size.x - (slot_size * 4 + slot_spacing * 3)) / 2
		slot.position = Vector2(x_pos + i * (slot_size + slot_spacing), get_viewport_rect().size.y - slot_size - 20)
		slot.size = Vector2(slot_size, slot_size)

		# 添加背景色
		var bg: ColorRect = ColorRect.new()
		bg.color = Color(0.2, 0.2, 0.2, 0.8)
		bg.size = Vector2(slot_size, slot_size)
		slot.add_child(bg)

		# 添加按键提示
		var key_label: Label = Label.new()
		key_label.name = "KeyLabel"
		key_label.text = str(i + 1)
		key_label.position = Vector2(5, 5)
		key_label.add_theme_color_override("font_color", Color(1, 1, 0.5))
		slot.add_child(key_label)

		# 添加技能名称标签
		var name_label: Label = Label.new()
		name_label.name = "NameLabel"
		name_label.text = "[空]"
		name_label.position = Vector2(5, 25)
		name_label.add_theme_font_size_override("font_size", 10)
		slot.add_child(name_label)

		add_child(slot)
		skill_slots.append(slot)

func _process(_delta: float) -> void:
	# 检测技能按键
	for i in range(4):
		if Input.is_action_just_pressed("skill_" + str(i + 1)):
			_use_skill(i)

	_update_display()

func _update_display() -> void:
	var equipped = SkillManager.get_equipped_skills()

	for i in range(4):
		var slot: Panel = skill_slots[i]
		var name_label: Label = slot.get_node_or_null("NameLabel")

		if name_label:
			if i < equipped.size() and equipped[i]:
				var skill_data: Dictionary = equipped[i]
				name_label.text = skill_data.get("name", "?").substr(0, 10)
				# 根据降级程度改变颜色
				var deg: int = skill_data.get("degradation", 0)
				match deg:
					0: name_label.add_theme_color_override("font_color", Color(0, 1, 1))
					1: name_label.add_theme_color_override("font_color", Color(1, 1, 0))
					2: name_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
					3: name_label.add_theme_color_override("font_color", Color(1, 0, 0))
			else:
				name_label.text = "[空]"
				name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func _use_skill(slot_index: int) -> void:
	var equipped = SkillManager.get_equipped_skills()
	if slot_index < equipped.size() and equipped[slot_index]:
		var skill_data: Dictionary = equipped[slot_index]
		var deg: int = skill_data.get("degradation", 0)

		# 严重降级(3)时无法使用
		if deg >= 3:
			print("技能已损坏，无法使用！")
			return

		var skill_id: String = skill_data.get("id", "")

		print("使用技能: ", skill_data.get("name", "?"))

		# 根据技能ID执行效果
		match skill_id:
			"dash_strike":
				_dash_strike()
			"bullet_bloom":
				_bullet_bloom()
			"drain_process":
				_drain_process()
			"evasion_protocol":
				_evasion_protocol()

func _dash_strike() -> void:
	# 通知玩家执行冲刺
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player:
		player.dash_strike()

func _bullet_bloom() -> void:
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player:
		player.bullet_bloom()

func _drain_process() -> void:
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player:
		player.drain_process_active = true
		await get_tree().create_timer(10.0).timeout
		player.drain_process_active = false

func _evasion_protocol() -> void:
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player:
		player.evasion_protocol()
