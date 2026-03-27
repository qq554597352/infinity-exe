extends CanvasLayer

# ============ HUD 主控制器 ============
# 整合血量、Token、技能栏、Loop计数

@export var health_bar_width: float = 200.0
@export var health_bar_height: float = 20.0
@export var skill_slot_size: float = 64.0
@export var skill_spacing: float = 10.0

# 组件引用
var health_panel: Panel
var health_bar: ProgressBar
var token_panel: Panel
var token_label: Label
var loop_label: Label
var skill_slots: Array = []

# 玩家引用
var player: Node2D = null

func _ready() -> void:
	_create_hud()
	_connect_signals()
	_update_display()

func _process(_delta: float) -> void:
	# 更新玩家引用
	if player == null or not is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]

	# 更新血量显示
	_update_health_display()

	# 处理技能快捷键
	_handle_skill_input()

# ============ 创建 HUD ============

func _create_hud() -> void:
	_create_health_ui()
	_create_token_ui()
	_create_skill_ui()
	_create_loop_ui()

# 血量 UI (左上角)
func _create_health_ui() -> void:
	health_panel = Panel.new()
	health_panel.name = "HealthPanel"
	health_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	health_panel.position = Vector2(20, 20)
	health_panel.custom_minimum_size = Vector2(health_bar_width + 40, health_bar_height + 30)

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.8)
	bg.size = health_panel.custom_minimum_size
	health_panel.add_child(bg)

	var heart_icon: Label = Label.new()
	heart_icon.text = "❤"
	heart_icon.position = Vector2(10, 5)
	heart_icon.add_theme_font_size_override("font_size", 20)
	health_panel.add_child(heart_icon)

	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.position = Vector2(40, 8)
	health_bar.size = Vector2(health_bar_width, health_bar_height)
	health_bar.max_value = 5
	health_bar.value = 5
	health_bar.show_percentage = false
	health_bar.add_theme_stylebox_override("fill", _create_health_bar_style())
	health_panel.add_child(health_bar)

	var health_text: Label = Label.new()
	health_text.name = "HealthText"
	health_text.text = "5 / 5"
	health_text.position = Vector2(health_bar_width + 50, 8)
	health_text.add_theme_font_size_override("font_size", 14)
	health_panel.add_child(health_text)

	add_child(health_panel)

# Token UI (右上角)
func _create_token_ui() -> void:
	token_panel = Panel.new()
	token_panel.name = "TokenPanel"
	token_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	token_panel.position = Vector2(-170, 20)
	token_panel.custom_minimum_size = Vector2(150, 50)

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.8)
	bg.size = token_panel.custom_minimum_size
	token_panel.add_child(bg)

	var coin_icon: Label = Label.new()
	coin_icon.text = "◈"
	coin_icon.position = Vector2(15, 12)
	coin_icon.add_theme_font_size_override("font_size", 24)
	coin_icon.add_theme_color_override("font_color", Color(1, 0.84, 0))
	token_panel.add_child(coin_icon)

	token_label = Label.new()
	token_label.name = "TokenLabel"
	token_label.text = "0"
	token_label.position = Vector2(50, 15)
	token_label.add_theme_font_size_override("font_size", 20)
	token_label.add_theme_color_override("font_color", Color(1, 1, 1))
	token_panel.add_child(token_label)

	add_child(token_panel)

# Loop 计数 UI (Token 下方)
func _create_loop_ui() -> void:
	var loop_panel: Panel = Panel.new()
	loop_panel.name = "LoopPanel"
	loop_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	loop_panel.position = Vector2(-170, 80)
	loop_panel.custom_minimum_size = Vector2(150, 35)

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.6)
	bg.size = loop_panel.custom_minimum_size
	loop_panel.add_child(bg)

	var loop_icon: Label = Label.new()
	loop_icon.text = "∞"
	loop_icon.position = Vector2(15, 5)
	loop_icon.add_theme_font_size_override("font_size", 18)
	loop_icon.add_theme_color_override("font_color", Color(0.5, 0.8, 1))
	loop_panel.add_child(loop_icon)

	loop_label = Label.new()
	loop_label.name = "LoopLabel"
	loop_label.text = "Loop: 0"
	loop_label.position = Vector2(50, 8)
	loop_label.add_theme_font_size_override("font_size", 14)
	loop_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	loop_panel.add_child(loop_label)

	add_child(loop_panel)

# 技能栏 UI (底部中央)
func _create_skill_ui() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var total_width: float = skill_slot_size * 4 + skill_spacing * 3
	var start_x: float = (viewport_size.x - total_width) / 2
	var y_pos: float = viewport_size.y - skill_slot_size - 20

	for i in range(4):
		var slot: Panel = _create_skill_slot(i)
		slot.position = Vector2(start_x + i * (skill_slot_size + skill_spacing), y_pos)
		add_child(slot)
		skill_slots.append(slot)

func _create_skill_slot(index: int) -> Panel:
	var slot: Panel = Panel.new()
	slot.name = "SkillSlot" + str(index)
	slot.custom_minimum_size = Vector2(skill_slot_size, skill_slot_size)

	# 背景
	var bg: ColorRect = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.15, 0.15, 0.2, 0.9)
	bg.size = Vector2(skill_slot_size, skill_slot_size)
	slot.add_child(bg)

	# 边框
	var border: ColorRect = ColorRect.new()
	border.name = "Border"
	border.color = Color(0.3, 0.3, 0.4, 1)
	border.size = Vector2(skill_slot_size, 2)
	border.position = Vector2(0, skill_slot_size - 2)
	slot.add_child(border)

	# 快捷键提示
	var key_label: Label = Label.new()
	key_label.name = "KeyLabel"
	key_label.text = str(index + 1)
	key_label.position = Vector2(5, 3)
	key_label.add_theme_font_size_override("font_size", 12)
	key_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	slot.add_child(key_label)

	# 技能名称
	var name_label: Label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = "[空]"
	name_label.position = Vector2(5, skill_slot_size - 25)
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size = Vector2(skill_slot_size - 10, 20)
	slot.add_child(name_label)

	return slot

func _create_health_bar_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.8, 0.2, 0.2, 1)  # 红色
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

# ============ 信号连接 ============

func _connect_signals() -> void:
	GameManager.token_changed.connect(_on_token_changed)
	GameManager.game_reset.connect(_on_game_reset)

# ============ 信号处理 ============

func _on_token_changed(new_amount: int) -> void:
	if token_label:
		token_label.text = str(new_amount)

	# Token 变化动画
	if token_label:
		var tween := create_tween()
		tween.tween_property(token_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(token_label, "scale", Vector2(1, 1), 0.1)

func _on_game_reset() -> void:
	_update_display()

# ============ 更新显示 ============

func _update_display() -> void:
	_update_token_display()
	_update_loop_display()
	_update_skill_display()

func _update_health_display() -> void:
	if player == null or not is_instance_valid(player):
		return

	if health_bar:
		var player_script = player as PlayerController
		if player_script:
			health_bar.value = player_script.current_health

			# 更新血条颜色
			var health_percent: float = float(player_script.current_health) / float(player_script.max_health)
			if health_percent > 0.6:
				health_bar.modulate = Color(0.2, 0.9, 0.3)  # 绿色
			elif health_percent > 0.3:
				health_bar.modulate = Color(1, 0.8, 0.2)  # 黄色
			else:
				health_bar.modulate = Color(0.9, 0.2, 0.2)  # 红色

	var health_text: Label = health_panel.get_node_or_null("HealthText")
	if health_text and player:
		var player_script = player as PlayerController
		if player_script:
			health_text.text = str(player_script.current_health) + " / " + str(player_script.max_health)

func _update_token_display() -> void:
	if token_label:
		token_label.text = str(GameManager.token)

func _update_loop_display() -> void:
	if loop_label:
		loop_label.text = "Loop: " + str(GameManager.loop_count)

func _update_skill_display() -> void:
	var equipped: Array = SkillManager.get_equipped_skills()

	for i in range(4):
		var slot: Panel = skill_slots[i]
		if slot == null:
			continue

		var bg: ColorRect = slot.get_node_or_null("Background")
		var name_label: Label = slot.get_node_or_null("NameLabel")

		if name_label == null:
			continue

		# 获取技能数据
		var skill_data = null
		if i < equipped.size():
			skill_data = equipped[i]

		if skill_data != null and typeof(skill_data) == TYPE_DICTIONARY:
			# 有技能
			var skill_name: String = str(skill_data.get("name", "?"))
			name_label.text = skill_name.substr(0, min(skill_name.length(), 8))

			# 降级颜色
			var deg: int = int(skill_data.get("degradation", 0))
			match deg:
				0: name_label.add_theme_color_override("font_color", Color(0, 1, 1))  # 青色
				1: name_label.add_theme_color_override("font_color", Color(1, 1, 0))  # 黄色
				2: name_label.add_theme_color_override("font_color", Color(1, 0.5, 0))  # 橙色
				3: name_label.add_theme_color_override("font_color", Color(1, 0, 0))  # 红色
				_: name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

			# 背景高亮
			if bg:
				bg.color = Color(0.2, 0.3, 0.4, 0.9)
		else:
			# 空槽
			name_label.text = "[空]"
			name_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
			if bg:
				bg.color = Color(0.15, 0.15, 0.2, 0.9)

# ============ 技能输入 ============

func _handle_skill_input() -> void:
	for i in range(4):
		if Input.is_action_just_pressed("skill_" + str(i + 1)):
			_use_skill(i)

func _use_skill(slot_index: int) -> void:
	var equipped: Array = SkillManager.get_equipped_skills()
	if slot_index >= equipped.size():
		return

	var skill_data = equipped[slot_index]
	if skill_data == null or typeof(skill_data) != TYPE_DICTIONARY:
		return

	# 检查降级
	var deg: int = int(skill_data.get("degradation", 0))
	if deg >= 3:
		print("技能已损坏，无法使用！")
		return

	var skill_id: String = str(skill_data.get("id", ""))
	print("使用技能: ", skill_id)

	match skill_id:
		"dash_strike":
			_exec_dash_strike()
		"bullet_bloom":
			_exec_bullet_bloom()
		"drain_process":
			_exec_drain_process()
		"evasion_protocol":
			_exec_evasion_protocol()

func _exec_dash_strike() -> void:
	if player and player.has_method("dash_strike"):
		player.dash_strike()

func _exec_bullet_bloom() -> void:
	if player and player.has_method("bullet_bloom"):
		player.bullet_bloom()

func _exec_drain_process() -> void:
	if player:
		player.drain_process_active = true
		await get_tree().create_timer(10.0).timeout
		player.drain_process_active = false

func _exec_evasion_protocol() -> void:
	if player and player.has_method("evasion_protocol"):
		player.evasion_protocol()
