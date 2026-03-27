extends CanvasLayer

# ============ 主菜单 ============

signal start_game
signal open_settings
signal quit_game

# 菜单状态
enum MenuState { MAIN, PLAYING, PAUSED }
var current_state: MenuState = MenuState.MAIN

# UI 组件
var title_label: Label
var start_button: Button
var settings_button: Button
var quit_button: Button
var version_label: Label

# 设置面板
var settings_panel: Panel
var volume_slider: HSlider
var music_volume_slider: HSlider

func _ready() -> void:
	_create_main_menu()

func _process(_delta: float) -> void:
	# 按 ESC 打开/关闭暂停菜单
	if Input.is_action_just_pressed("ui_cancel"):
		if current_state == MenuState.PLAYING:
			_show_pause_menu()
		elif current_state == MenuState.PAUSED:
			_hide_pause_menu()

# ============ 创建主菜单 ============

func _create_main_menu() -> void:
	# 全屏半透明背景
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.05, 0.05, 0.1, 0.95)
	bg.size = get_viewport().get_visible_rect().size
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 标题
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "∞.exe"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_CENTER)
	title_label.position = Vector2(-100, -150)
	title_label.size = Vector2(200, 80)
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	add_child(title_label)

	# 副标题
	var subtitle = Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "INFINITE LOOP"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_CENTER)
	subtitle.position = Vector2(-80, -70)
	subtitle.size = Vector2(160, 30)
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	add_child(subtitle)

	# 按钮容器
	var button_container = VBoxContainer.new()
	button_container.name = "ButtonContainer"
	button_container.set_anchors_preset(Control.PRESET_CENTER)
	button_container.position = Vector2(-80, 50)
	button_container.size = Vector2(160, 150)
	button_container.add_theme_constant_override("separation", 20)
	add_child(button_container)

	# 开始按钮
	start_button = _create_menu_button("START GAME")
	start_button.pressed.connect(_on_start_pressed)
	button_container.add_child(start_button)

	# 设置按钮
	settings_button = _create_menu_button("SETTINGS")
	settings_button.pressed.connect(_on_settings_pressed)
	button_container.add_child(settings_button)

	# 退出按钮
	quit_button = _create_menu_button("QUIT")
	quit_button.pressed.connect(_on_quit_pressed)
	button_container.add_child(quit_button)

	# 版本信息
	version_label = Label.new()
	version_label.name = "Version"
	version_label.text = "v0.1.0 MVP"
	version_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	version_label.position = Vector2(-120, -40)
	version_label.size = Vector2(100, 30)
	version_label.add_theme_font_size_override("font_size", 12)
	version_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.35))
	add_child(version_label)

	# 装饰线
	var decor_line = ColorRect.new()
	decor_line.name = "DecorLine"
	decor_line.color = Color(0.3, 0.1, 0.1, 0.5)
	decor_line.set_anchors_preset(Control.PRESET_CENTER)
	decor_line.position = Vector2(-150, -110)
	decor_line.size = Vector2(300, 2)
	add_child(decor_line)

func _create_menu_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 50)
	btn.add_theme_font_size_override("font_size", 18)

	# 按钮样式
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	normal_style.border_width_top = 1
	normal_style.border_width_bottom = 1
	normal_style.border_width_left = 1
	normal_style.border_width_right = 1
	normal_style.border_color = Color(0.3, 0.3, 0.4, 0.5)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.2, 0.2, 0.25, 0.9)
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_left = 4
	hover_style.corner_radius_bottom_right = 4
	hover_style.border_width_top = 1
	hover_style.border_width_bottom = 1
	hover_style.border_width_left = 1
	hover_style.border_width_right = 1
	hover_style.border_color = Color(0.58, 0.52, 1, 0.8)

	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", hover_style)

	return btn

# ============ 按钮回调 ============

func _on_start_pressed() -> void:
	print("开始游戏...")
	start_game.emit()
	current_state = MenuState.PLAYING

	# 延迟切换场景
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/levels/main_level.tscn")
	queue_free()

func _on_settings_pressed() -> void:
	_show_settings_panel()

func _on_quit_pressed() -> void:
	print("退出游戏...")
	quit_game.emit()
	get_tree().quit()

# ============ 设置面板 ============

func _show_settings_panel() -> void:
	settings_panel = Panel.new()
	settings_panel.name = "SettingsPanel"
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.position = Vector2(-200, -150)
	settings_panel.size = Vector2(400, 300)

	# 添加背景
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.98)
	bg.size = Vector2(400, 300)
	settings_panel.add_child(bg)

	var title = Label.new()
	title.text = "SETTINGS"
	title.position = Vector2(140, 20)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	settings_panel.add_child(title)

	# 主音量
	var master_label = Label.new()
	master_label.text = "Master Volume"
	master_label.position = Vector2(30, 70)
	master_label.add_theme_font_size_override("font_size", 14)
	settings_panel.add_child(master_label)

	volume_slider = HSlider.new()
	volume_slider.position = Vector2(30, 95)
	volume_slider.size = Vector2(340, 20)
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.value = 80
	volume_slider.value_changed.connect(_on_volume_changed)
	settings_panel.add_child(volume_slider)

	# 音乐音量
	var music_label = Label.new()
	music_label.text = "Music Volume"
	music_label.position = Vector2(30, 130)
	music_label.add_theme_font_size_override("font_size", 14)
	settings_panel.add_child(music_label)

	music_volume_slider = HSlider.new()
	music_volume_slider.position = Vector2(30, 155)
	music_volume_slider.size = Vector2(340, 20)
	music_volume_slider.min_value = 0
	music_volume_slider.max_value = 100
	music_volume_slider.value = 60
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	settings_panel.add_child(music_volume_slider)

	# 关闭按钮
	var close_btn = Button.new()
	close_btn.text = "CLOSE"
	close_btn.position = Vector2(150, 240)
	close_btn.size = Vector2(100, 40)
	close_btn.pressed.connect(_hide_settings_panel)
	settings_panel.add_child(close_btn)

	add_child(settings_panel)

func _hide_settings_panel() -> void:
	if settings_panel:
		settings_panel.queue_free()
		settings_panel = null

func _on_volume_changed(value: float) -> void:
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("set_master_volume"):
		audio_manager.set_master_volume(value / 100.0)

func _on_music_volume_changed(value: float) -> void:
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("set_music_volume"):
		audio_manager.set_music_volume(value / 100.0)

# ============ 暂停菜单 ============

func _show_pause_menu() -> void:
	current_state = MenuState.PAUSED
	get_tree().paused = true

	# 创建暂停背景
	var pause_bg = ColorRect.new()
	pause_bg.name = "PauseBackground"
	pause_bg.color = Color(0, 0, 0, 0.7)
	pause_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(pause_bg)

	# 暂停标题
	var pause_title = Label.new()
	pause_title.text = "PAUSED"
	pause_title.set_anchors_preset(Control.PRESET_CENTER)
	pause_title.add_theme_font_size_override("font_size", 48)
	pause_title.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(pause_title)

	# 继续按钮
	var resume_btn = _create_menu_button("RESUME")
	resume_btn.set_anchors_preset(Control.PRESET_CENTER)
	resume_btn.position.y = 50
	resume_btn.pressed.connect(_on_resume_pressed)
	add_child(resume_btn)

	# 返回主菜单按钮
	var menu_btn = _create_menu_button("MAIN MENU")
	menu_btn.set_anchors_preset(Control.PRESET_CENTER)
	menu_btn.position.y = 120
	menu_btn.pressed.connect(_on_return_to_menu)
	add_child(menu_btn)

func _hide_pause_menu() -> void:
	current_state = MenuState.PLAYING
	get_tree().paused = false

	# 删除暂停菜单的子节点
	for child in get_children():
		if child.name in ["PauseBackground"]:
			child.queue_free()
		elif child is Button:
			child.queue_free()
		elif child is Label and child.text == "PAUSED":
			child.queue_free()

func _on_resume_pressed() -> void:
	_hide_pause_menu()

func _on_return_to_menu() -> void:
	_hide_pause_menu()
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
