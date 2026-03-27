extends CharacterBody2D
class_name Architect

# ============ 基础参数 ============
@export var max_health: int = 20       # Boss 高生命值
@export var damage: int = 2             # 更高伤害
@export var token_drop: int = 50        # Boss 击杀高奖励

# ============ 移动参数 ============
@export var speed: float = 80.0         # 移动速度
@export var chase_speed: float = 150.0  # 追踪速度

# ============ 攻击参数 ============
@export var melee_range: float = 80.0    # 近战攻击范围
@export var ranged_attack_range: float = 400.0  # 远程攻击范围
@export var attack_cooldown: float = 1.5

# ============ 阶段参数 ============
@export var phase2_health_threshold: float = 0.5  # 50% 进入第二阶段
@export var phase3_health_threshold: float = 0.2  # 20% 进入第三阶段

# ============ 状态 ============
enum State { IDLE, CHASE, MELEE_ATTACK, RANGED_ATTACK, SUMMON, HURT, PHASE_CHANGE, DEAD }
enum Phase { PHASE_1, PHASE_2, PHASE_3 }

var current_state: State = State.IDLE
var current_phase: Phase = Phase.PHASE_1
var current_health: int
var max_health_value: int
var is_dead: bool = false
var can_attack: bool = true
var attack_cooldown_timer: float = 0.0

# ============ 玩家引用 ============
var player: Node2D = null

# ============ 视觉组件 ============
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_bar_bg: ColorRect = $HealthBarBG
@onready var sprite: ColorRect = $ColorRect
@onready var hitbox: Area2D = $Hitbox

# ============ 特效 ============
var is_invincible: bool = false

func _ready() -> void:
	max_health_value = max_health
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

	add_to_group("enemies")
	add_to_group("boss")

	# Boss 血条默认显示
	health_bar.visible = true
	health_bar_bg.visible = true

	print("ARCHITECT 已激活...")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 更新攻击冷却
	if not can_attack:
		attack_cooldown_timer -= delta
		if attack_cooldown_timer <= 0:
			can_attack = true

	match current_state:
		State.IDLE:
			_idle_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.MELEE_ATTACK:
			_pass  # 在动画中处理
		State.RANGED_ATTACK:
			_ranged_attack_state()
		State.SUMMON:
			_pass
		State.HURT:
			_pass
		State.PHASE_CHANGE:
			_phase_change_state()
		State.DEAD:
			_dead_state()

	# 检查阶段变化
	_check_phase_transition()

func _idle_state(delta: float) -> void:
	velocity = Vector2.ZERO

	# 检测玩家
	player = _find_player()
	if player:
		current_state = State.CHASE
		print("ARCHITECT 发现目标！")

func _chase_state(delta: float) -> void:
	if not player or not is_instance_valid(player):
		current_state = State.IDLE
		return

	var direction := global_position.direction_to(player.global_position)
	var distance := global_position.distance_to(player.global_position)

	# 根据距离决定行为
	if distance < melee_range:
		# 近战范围 - 发动近战攻击
		if can_attack:
			_melee_attack()
	elif distance < ranged_attack_range:
		# 中距离 - 追踪玩家
		velocity = direction * chase_speed
	else:
		# 远距离 - 快速接近
		velocity = direction * chase_speed * 1.5

	move_and_slide()

	# 更新面向
	_update_facing(direction)

	# 随机发动远程攻击
	if can_attack and randf() < 0.01 * delta * 60:  # 每秒约1%几率
		_ranged_attack()

func _melee_attack() -> void:
	can_attack = false
	attack_cooldown_timer = attack_cooldown
	current_state = State.MELEE_ATTACK

	# 伤害判定
	if player and is_instance_valid(player):
		var distance := global_position.distance_to(player.global_position)
		if distance < melee_range * 1.5:
			player.take_damage(damage)
			print("ARCHITECT 近战攻击！造成 ", damage, " 伤害")

	# 攻击特效
	_attack_effect()

	await get_tree().create_timer(0.5).timeout
	current_state = State.CHASE

func _ranged_attack() -> void:
	if not can_attack:
		return

	can_attack = false
	attack_cooldown_timer = attack_cooldown + 1.0  # 远程攻击冷却更长
	current_state = State.RANGED_ATTACK

	# 创建投射物
	_spawn_projectile()

	await get_tree().create_timer(0.8).timeout
	current_state = State.CHASE

func _ranged_attack_state() -> void:
	# 远程攻击状态（播放动画）
	pass

func _spawn_projectile() -> void:
	if not player or not is_instance_valid(player):
		return

	# 创建投射物场景（复用或新建）
	var projectile = Area2D.new()
	projectile.name = "BossProjectile"

	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 10.0
	collision.shape = shape
	projectile.add_child(collision)

	var visual = ColorRect.new()
	visual.color = Color(1, 0, 0.5, 1)  # 紫色投射物
	visual.size = Vector2(20, 20)
	visual.position = Vector2(-10, -10)
	projectile.add_child(visual)

	projectile.position = global_position

	# 设置投射物脚本
	var proj_script = GDScript.new()
	proj_script.source_code = """
extends Area2D

var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO
var damage: int = 1
var lifetime: float = 3.0

func _ready() -> void:
	add_to_group(\"boss_projectiles\")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(\"player\"):
		if body.has_method(\"take_damage\"):
			body.take_damage(damage)
		queue_free()
	elif body.is_in_group(\"walls\"):
		queue_free()
"""
	projectile.set_script(proj_script)

	# 设置方向（朝向玩家）
	var to_player = player.global_position - global_position
	projectile.direction = to_player.normalized()

	# 添加碰撞检测
	projectile.body_entered.connect(_on_projectile_hit.bind(projectile))

	get_parent().add_child(projectile)
	print("ARCHITECT 发射投射物！")

func _on_projectile_hit(body: Node, projectile: Area2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		projectile.queue_free()
	elif body.is_in_group("walls") or body.is_in_group("enemies"):
		projectile.queue_free()

func _attack_effect() -> void:
	# 红色闪烁
	sprite.color = Color(1, 0.3, 0.3, 1)
	await get_tree().create_timer(0.2).timeout
	sprite.color = Color(1, 1, 1, 1)

func _check_phase_transition() -> void:
	var health_percent := float(current_health) / float(max_health_value)

	if health_percent <= phase3_health_threshold and current_phase < Phase.PHASE_3:
		_enter_phase_3()
	elif health_percent <= phase2_health_threshold and current_phase < Phase.PHASE_2:
		_enter_phase_2()

func _enter_phase_2() -> void:
	current_phase = Phase.PHASE_2
	current_state = State.PHASE_CHANGE
	print("ARCHITECT 进入第二阶段！")

	# 第二阶段特效
	_modulate_phase_effect()

	# 增加移动速度
	chase_speed *= 1.3

	await get_tree().create_timer(1.5).timeout
	current_state = State.CHASE

func _enter_phase_3() -> void:
	current_phase = Phase.PHASE_3
	current_state = State.PHASE_CHANGE
	print("ARCHITECT 进入第三阶段！")

	# 第三阶段特效
	_modulate_phase_effect()

	# 进一步增强
	chase_speed *= 1.5
	attack_cooldown *= 0.7

	# 召唤小兵
	_summon_minions()

	await get_tree().create_timer(2.0).timeout
	current_state = State.CHASE

func _modulate_phase_effect() -> void:
	# 阶段变化时的视觉效果
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.5, 0, 1), 0.3)
	await get_tree().create_timer(0.3).timeout
	tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.3)

func _phase_change_state() -> void:
	# 阶段变化时停止移动
	velocity = Vector2.ZERO

func _summon_minions() -> void:
	# 第三阶段召唤小兵
	var minion_scene = load("res://scenes/enemies/tracker.tscn")
	if minion_scene:
		for i in range(2):
			var minion = minion_scene.instantiate()
			minion.position = global_position + Vector2(randf_range(-100, 100), randf_range(-50, 50))
			minion.max_health = 2  # 强化小兵
			minion.speed = 150
			get_parent().add_child(minion)
		print("ARCHITECT 召唤了小兵！")

func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var p = players[0]
		var distance := global_position.distance_to(p.global_position)
		if distance < ranged_attack_range * 1.5:
			return p
	return null

func _update_facing(direction: Vector2) -> void:
	if direction.x > 0.1:
		sprite.scale.x = 1
	elif direction.x < -0.1:
		sprite.scale.x = -1

func hit_player(player_ref: Node2D) -> void:
	if is_dead or is_invincible:
		return
	player = player_ref

func take_damage(amount: int) -> void:
	if is_dead or is_invincible:
		return

	is_invincible = true
	current_health -= amount
	health_bar.value = current_health

	print("ARCHITECT 受伤！剩余: ", current_health, "/", max_health_value)

	# 受伤效果
	_hurt_effect()

	# 无敌帧
	await get_tree().create_timer(0.1).timeout
	is_invincible = false

	if current_health <= 0:
		die()

func _hurt_effect() -> void:
	sprite.color = Color(0.5, 0.5, 1, 1)  # 蓝色闪烁
	await get_tree().create_timer(0.1).timeout
	sprite.color = Color(1, 1, 1, 1)

func _dead_state() -> void:
	velocity = Vector2.ZERO
	# 死亡动画播放中

func die() -> void:
	if is_dead:
		return

	is_dead = true
	current_state = State.DEAD

	print("========== ARCHITECT 已击败！ ==========")
	print("获得 ", token_drop, " Token！")

	if GameManager:
		GameManager.add_token(token_drop)
		# Boss 击杀可能掉落多个技能碎片
		for i in range(3):
			if randf() < 0.7:
				_spawn_skill_fragment()

	# 死亡动画
	_death_animation()

	await get_tree().create_timer(2.0).timeout
	queue_free()

func _death_animation() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.5)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 1.0)

	# 隐藏血条
	health_bar.visible = false
	health_bar_bg.visible = false

func _spawn_skill_fragment() -> void:
	var fragment = load("res://scenes/items/skill_fragment.tscn").instantiate()
	fragment.position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	get_parent().add_child(fragment)
	print("Boss 掉落技能碎片！")
