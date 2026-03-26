extends CanvasLayer

# 技能UI - 显示底部4个技能槽位

@export var slot_size: int = 64
@export var slot_spacing: int = 10

var skill_slots: Array = []

func _ready() -> void:
	_create_skill_slots()

func _create_skill_slots() -> void:
	for i in range(4):
		var slot: Panel = Panel.new()
		slot.name = "SkillSlot" + str(i)

		# 获取视口大小
		var viewport_size: Vector2 = get_viewport().get_visible_rect().size
		var x_pos: float = (viewport_size.x - (slot_size * 4 + slot_spacing * 3)) / 2
		slot.position = Vector2(x_pos + i * (slot_size + slot_spacing), viewport_size.y - slot_size - 20)
		slot.size = Vector2(slot_size, slot_size)

		var bg: ColorRect = ColorRect.new()
		bg.color = Color(0.2, 0.2, 0.2, 0.8)
		bg.size = Vector2(slot_size, slot_size)
		slot.add_child(bg)

		var key_label: Label = Label.new()
		key_label.name = "KeyLabel"
		key_label.text = str(i + 1)
		key_label.position = Vector2(5, 5)
		slot.add_child(key_label)

		var name_label: Label = Label.new()
		name_label.name = "NameLabel"
		name_label.text = "[空]"
		name_label.position = Vector2(5, 25)
		name_label.add_theme_font_size_override("font_size", 10)
		slot.add_child(name_label)

		add_child(slot)
		skill_slots.append(slot)

func _process(_delta: float) -> void:
	for i in range(4):
		if Input.is_action_just_pressed("skill_" + str(i + 1)):
			_use_skill(i)
	_update_display()

func _update_display() -> void:
	var equipped: Array = SkillManager.get_equipped_skills()

	for i in range(4):
		var slot: Panel = skill_slots[i]
		var name_label: Label = slot.get_node_or_null("NameLabel")

		if name_label != null:
			var skill_data: Dictionary = equipped[i] if i < equipped.size() else {}
			if not skill_data.is_empty():
				var skill_name: String = skill_data.get("name", "?")
				name_label.text = skill_name.substr(0, min(skill_name.length(), 10))

				var deg: int = 0
				if "degradation" in skill_data:
					deg = skill_data["degradation"]

				match deg:
					0: name_label.add_theme_color_override("font_color", Color(0, 1, 1))
					1: name_label.add_theme_color_override("font_color", Color(1, 1, 0))
					2: name_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
					3: name_label.add_theme_color_override("font_color", Color(1, 0, 0))
			else:
				name_label.text = "[空]"
				name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func _use_skill(slot_index: int) -> void:
	var equipped: Array = SkillManager.get_equipped_skills()
	if slot_index >= equipped.size():
		return

	var skill_data: Dictionary = equipped[slot_index]
	if skill_data.is_empty():
		return

	var deg: int = 0
	if "degradation" in skill_data:
		deg = skill_data["degradation"]

	if deg >= 3:
		print("技能已损坏，无法使用！")
		return

	var skill_id: String = ""
	if "id" in skill_data:
		skill_id = skill_data["id"]

	print("使用技能: ", skill_id)

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
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player != null:
		player.dash_strike()

func _bullet_bloom() -> void:
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player != null:
		player.bullet_bloom()

func _drain_process() -> void:
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player != null:
		player.drain_process_active = true
		await get_tree().create_timer(10.0).timeout
		player.drain_process_active = false

func _evasion_protocol() -> void:
	var player: PlayerController = get_tree().get_first_node_in_group("player")
	if player != null:
		player.evasion_protocol()
