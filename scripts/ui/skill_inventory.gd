extends CanvasLayer

# 技能仓库UI - 按Tab打开，显示拥有技能和装备槽位

var inventory_panel: Panel
var is_visible: bool = false

func _ready() -> void:
	_create_inventory_ui()
	visibility_changed.connect(_on_visibility_changed)

func _create_inventory_ui() -> void:
	# 创建仓库面板
	inventory_panel = Panel.new()
	inventory_panel.name = "SkillInventory"
	inventory_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	inventory_panel.custom_minimum_size = Vector2(500, 400)
	inventory_panel.visible = false

	# 背景
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.95)
	bg.size = Vector2(500, 400)
	bg.position = Vector2(0, 0)
	inventory_panel.add_child(bg)

	# 标题
	var title: Label = Label.new()
	title.text = "技能仓库 [Tab关闭]"
	title.position = Vector2(20, 15)
	title.add_theme_font_size_override("font_size", 20)
	inventory_panel.add_child(title)

	# 装备区域标题
	var equip_label: Label = Label.new()
	equip_label.text = "已装备 (按1-4键卸下)"
	equip_label.position = Vector2(20, 60)
	equip_label.add_theme_font_size_override("font_size", 14)
	inventory_panel.add_child(equip_label)

	# 装备槽位
	for i in range(4):
		var slot: Panel = _create_equip_slot(i)
		slot.position = Vector2(20 + i * 80, 85)
		inventory_panel.add_child(slot)

	# 拥有技能区域标题
	var owned_label: Label = Label.new()
	owned_label.text = "拥有技能 (点击装备到空槽)"
	owned_label.position = Vector2(20, 180)
	owned_label.add_theme_font_size_override("font_size", 14)
	inventory_panel.add_child(owned_label)

	# 拥有技能列表容器
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "OwnedScroll"
	scroll.position = Vector2(20, 210)
	scroll.size = Vector2(460, 180)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory_panel.add_child(scroll)

	var list: VBoxContainer = VBoxContainer.new()
	list.name = "OwnedList"
	list.custom_minimum_size = Vector2(440, 170)
	list.add_theme_constant_override("separation", 5)
	scroll.add_child(list)

	add_child(inventory_panel)

func _create_equip_slot(index: int) -> Panel:
	var slot: Panel = Panel.new()
	slot.name = "EquipSlot" + str(index)
	slot.custom_minimum_size = Vector2(70, 70)

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.25, 0.9)
	bg.size = Vector2(70, 70)
	slot.add_child(bg)

	var key_label: Label = Label.new()
	key_label.name = "KeyLabel"
	key_label.text = str(index + 1)
	key_label.position = Vector2(5, 5)
	slot.add_child(key_label)

	var name_label: Label = Label.new()
	name_label.name = "SkillName"
	name_label.text = "[空]"
	name_label.position = Vector2(5, 30)
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_child(name_label)

	return slot

func _process(_delta: float) -> void:
	# Tab键切换显示
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_inventory()

	# 1-4键卸下装备
	for i in range(4):
		if Input.is_action_just_pressed("skill_" + str(i + 1)) and is_visible:
			_unequip_slot(i)

func _toggle_inventory() -> void:
	is_visible = !is_visible
	inventory_panel.visible = is_visible
	_update_display()

	# 暂停游戏
	if is_visible:
		get_tree().paused = true
	else:
		get_tree().paused = false

func _on_visibility_changed() -> void:
	if inventory_panel.visible:
		_update_display()

func _update_display() -> void:
	if inventory_panel == null:
		return

	# 更新装备槽
	var equipped: Array = SkillManager.get_equipped_skills()
	for i in range(4):
		var slot_path: String = "EquipSlot" + str(i)
		var slot: Panel = inventory_panel.get_node_or_null(slot_path)
		if slot != null:
			var name_label: Label = slot.get_node_or_null("SkillName")
			if name_label != null:
				var skill_data = null
				if i < equipped.size():
					skill_data = equipped[i]
				if skill_data != null and typeof(skill_data) == TYPE_DICTIONARY:
					name_label.text = str(skill_data.get("name", "?")).substr(0, 8)
					name_label.add_theme_color_override("font_color", _get_degradation_color(skill_data))
				else:
					name_label.text = "[空]"
					name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

	# 更新拥有列表
	var list_path: NodePath = NodePath("OwnedList")
	var scroll: ScrollContainer = inventory_panel.get_node_or_null("OwnedScroll")
	if scroll != null:
		var list: VBoxContainer = scroll.get_node_or_null(list_path)
		if list != null:
			# 清除旧内容
			for child in list.get_children():
				child.queue_free()

			var owned: Array = SkillManager.get_owned_skills()
			for idx in range(owned.size()):
				var skill_data = owned[idx]
				if skill_data != null and typeof(skill_data) == TYPE_DICTIONARY:
					var btn: Button = _create_skill_button(idx, skill_data)
					list.add_child(btn)

func _create_skill_button(index: int, skill_data: Dictionary) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(440, 35)

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.2, 0.9)
	bg.size = Vector2(440, 35)
	btn.add_child(bg)

	var name_label: Label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = str(skill_data.get("name", "?"))
	name_label.position = Vector2(10, 8)
	name_label.add_theme_color_override("font_color", _get_degradation_color(skill_data))
	btn.add_child(name_label)

	var id_label: Label = Label.new()
	id_label.name = "IdLabel"
	id_label.text = "[" + str(skill_data.get("id", "?")) + "]"
	id_label.position = Vector2(150, 8)
	id_label.add_theme_font_size_override("font_size", 12)
	btn.add_child(id_label)

	btn.pressed.connect(_on_skill_button_pressed.bind(index))

	return btn

func _get_degradation_color(skill_data: Dictionary) -> Color:
	var deg: int = int(skill_data.get("degradation", 0))
	match deg:
		0: return Color(0, 1, 1)       # 青色
		1: return Color(1, 1, 0)       # 黄色
		2: return Color(1, 0.5, 0)     # 橙色
		3: return Color(1, 0, 0)       # 红色
	return Color(1, 1, 1)

func _on_skill_button_pressed(skill_index: int) -> void:
	var owned: Array = SkillManager.get_owned_skills()
	if skill_index >= owned.size():
		return

	var skill_data = owned[skill_index]

	# 找到第一个空槽装备
	for i in range(4):
		var equipped: Array = SkillManager.get_equipped_skills()
		if i >= equipped.size() or equipped[i] == null:
			if SkillManager.equip_skill(i, skill_data):
				print("已装备: ", skill_data.get("name", "?"))
				_update_display()
				return

	print("没有空槽位!")

func _unequip_slot(slot_index: int) -> void:
	var unequipped = SkillManager.unequip_skill(slot_index)
	if not unequipped.is_empty():
		print("已卸下: ", unequipped.get("name", "?"))
	_update_display()
