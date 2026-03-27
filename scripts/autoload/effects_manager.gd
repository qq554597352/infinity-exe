extends Node

# ============ 粒子特效管理器 ============
# 管理所有游戏内的粒子特效

# 特效节点容器
var effects_container: Node2D

func _ready() -> void:
	_create_effects_container()

func _create_effects_container() -> void:
	effects_container = Node2D.new()
	effects_container.name = "EffectsContainer"
	add_child(effects_container)

# ============ 攻击特效 ============

func spawn_attack_effect(position: Vector2, direction: int) -> void:
	# 快速闪烁的刀光特效
	var effect = _create_rect_effect(
		position + Vector2(40 * direction, 0),
		Vector2(60, 30),
		Color(1, 0.8, 0.3, 0.8),
		0.15
	)
	effect.z_index = 10
	_add_effect(effect)

# ============ 技能特效 ============

func spawn_dash_trail(position: Vector2, direction: int) -> void:
	# 冲锋残影特效
	for i in range(3):
		var effect = _create_rect_effect(
			position + Vector2(-10 * i * direction, 0),
			Vector2(30, 40),
			Color(0, 1, 1, 0.5 - i * 0.15),
			0.3 + i * 0.1
		)
		effect.z_index = -1
		_add_effect(effect)

func spawn_bullet_bloom_effect(position: Vector2) -> void:
	# 弹幕格挡 - 环形扩散特效
	var effect = _create_circle_effect(position, 80, Color(0, 1, 1, 0.7), 0.3)
	effect.z_index = 10
	_add_effect(effect)

func spawn_evasion_effect(position: Vector2, direction: int) -> void:
	# 闪避特效 - 多重残影
	for i in range(5):
		var offset = Vector2(-30 * i * direction, randf_range(-20, 20))
		var effect = _create_rect_effect(
			position + offset,
			Vector2(25, 35),
			Color(1, 0.5, 0, 0.6 - i * 0.1),
			0.2 + i * 0.05
		)
		effect.modulate.a = 0.8 - i * 0.15
		_add_effect(effect)

func spawn_skill_ready(position: Vector2) -> void:
	# 技能就绪光环
	var effect = _create_circle_effect(position, 50, Color(0, 1, 1, 0.6), 0.5)
	effect.z_index = 5
	_add_effect(effect)

# ============ 伤害特效 ============

func spawn_hit_effect(position: Vector2) -> void:
	# 受伤特效 - 红色闪烁
	var effect = _create_rect_effect(
		position,
		Vector2(40, 50),
		Color(1, 0.2, 0.2, 0.8),
		0.2
	)
	effect.z_index = 10
	_add_effect(effect)

func spawn_player_hit_effect(position: Vector2) -> void:
	# 玩家受伤 - 屏幕边缘红色闪烁
	var effect = _create_rect_effect(
		position,
		Vector2(50, 50),
		Color(1, 0, 0, 0.6),
		0.15
	)
	effect.z_index = 100
	_add_effect(effect)

# ============ 死亡特效 ============

func spawn_enemy_death_effect(position: Vector2, color: Color = Color(1, 0.3, 0.3)) -> void:
	# 敌人死亡特效 - 爆炸扩散
	for i in range(8):
		var angle = i * PI / 4
		var offset = Vector2(cos(angle) * 20, sin(angle) * 20)
		var effect = _create_rect_effect(
			position + offset,
			Vector2(15, 15),
			color,
			0.4
		)
		effect.scale = Vector2(0.5, 0.5)
		_add_effect(effect)

	# 中心爆炸
	var center = _create_rect_effect(position, Vector2(30, 30), color, 0.3)
	_add_effect(center)

func spawn_boss_death_effect(position: Vector2) -> void:
	# Boss 死亡 - 大型爆炸
	for wave in range(3):
		for i in range(12):
			var angle = i * PI / 6 + wave * 0.2
			var distance = 30 + wave * 25
			var offset = Vector2(cos(angle) * distance, sin(angle) * distance)
			var effect = _create_rect_effect(
				position + offset,
				Vector2(20 + wave * 5, 20 + wave * 5),
				Color(0.8, 0.2, 0.8, 0.8 - wave * 0.2),
				0.5 + wave * 0.2
			)
			_add_effect(effect)

	# 中心闪光
	var flash = _create_circle_effect(position, 100, Color(1, 1, 1, 0.9), 0.6)
	_add_effect(flash)

func spawn_player_death_effect(position: Vector2) -> void:
	# 玩家死亡 - 碎片飘散
	for i in range(10):
		var offset = Vector2(randf_range(-30, 30), randf_range(-50, 10))
		var effect = _create_rect_effect(
			position + offset,
			Vector2(8, 8),
			Color(0.3, 0.5, 1, 0.8),
			0.8
		)
		_add_effect(effect)

func spawn_respawn_effect(position: Vector2) -> void:
	# 复活特效 - 聚合光环
	for i in range(3):
		var delay = i * 0.15
		var effect = _create_circle_effect(position, 30 + i * 20, Color(0.3, 0.5, 1, 0.7), 0.4)
		effect.z_index = 10
		_add_effect(effect)

# ============ 物品特效 ============

func spawn_pickup_effect(position: Vector2) -> void:
	# 拾取特效 - 上浮光点
	for i in range(5):
		var offset = Vector2(randf_range(-15, 15), randf_range(-10, 10))
		var effect = _create_rect_effect(
			position + offset + Vector2(0, -i * 10),
			Vector2(8, 8),
			Color(0, 1, 1, 0.8 - i * 0.15),
			0.4 + i * 0.1
		)
		_add_effect(effect)

func spawn_token_gain_effect(position: Vector2) -> void:
	# Token 获得特效
	var effect = _create_rect_effect(
		position,
		Vector2(20, 20),
		Color(1, 0.84, 0, 0.9),
		0.5
	)
	effect.z_index = 50
	_add_effect(effect)

# ============ 敌人特效 ============

func spawn_tracker_detect_effect(position: Vector2) -> void:
	# Tracker 发现玩家时
	var effect = _create_circle_effect(position, 40, Color(0.2, 0.4, 1, 0.6), 0.3)
	effect.z_index = 5
	_add_effect(effect)

func spawn_boss_phase_change_effect(position: Vector2, phase: int) -> void:
	# Boss 阶段变化
	var colors = [
		Color(1, 0.5, 0, 0.8),  # Phase 2 - 橙色
		Color(1, 0, 0.5, 0.8)   # Phase 3 - 红色
	]
	var color = colors[phase - 2] if phase >= 2 else Color(1, 1, 0, 0.8)

	for i in range(6):
		var angle = i * PI / 3
		var offset = Vector2(cos(angle) * 50, sin(angle) * 50)
		var effect = _create_rect_effect(
			position + offset,
			Vector2(20, 20),
			color,
			0.5
		)
		_add_effect(effect)

func spawn_projectile_effect(position: Vector2) -> void:
	# 投射物特效
	var effect = _create_circle_effect(position, 15, Color(1, 0, 0.5, 0.8), 0.3)
	effect.z_index = 5
	_add_effect(effect)

# ============ 环境特效 ============

func spawn_land_effect(position: Vector2) -> void:
	# 落地尘土效果
	for i in range(4):
		var offset = Vector2(randf_range(-20, 20), 0)
		var effect = _create_rect_effect(
			position + offset,
			Vector2(10, 5),
			Color(0.5, 0.5, 0.5, 0.5),
			0.3
		)
		_add_effect(effect)

# ============ 工具方法 ============

func _create_rect_effect(position: Vector2, size: Vector2, color: Color, lifetime: float) -> Node2D:
	var node = Node2D.new()
	node.position = position

	var rect = ColorRect.new()
	rect.position = -size / 2
	rect.size = size
	rect.color = color
	node.add_child(rect)

	_add_fade_out(node, lifetime)

	return node

func _create_circle_effect(position: Vector2, radius: float, color: Color, lifetime: float) -> Node2D:
	var node = Node2D.new()
	node.position = position

	var circle = ColorRect.new()
	circle.size = Vector2(radius * 2, radius * 2)
	circle.position = -Vector2(radius, radius)
	circle.color = color
	circle.custom_minimum_size = Vector2(radius * 2, radius * 2)
	circle.set("size", Vector2(radius * 2, radius * 2))  # 确保尺寸正确
	node.add_child(circle)

	_add_fade_out(node, lifetime)

	return node

func _add_fade_out(node: Node2D, lifetime: float) -> void:
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, lifetime)
	tween.tween_callback(node.queue_free)

func _add_effect(effect: Node2D) -> void:
	if effects_container:
		effects_container.add_child(effect)
	else:
		add_child(effect)
