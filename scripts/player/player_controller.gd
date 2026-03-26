extends CharacterBody2D
class_name PlayerController

# 移动参数
@export var speed: float = 300.0        # 移动速度
@export var jump_force: float = -450.0  # 跳跃力（负数是向上）
@export var gravity: float = 1200.0    # 重力

# 生命参数
@export var max_health: int = 5        # 最大生命值
var current_health: int                 # 当前生命值
var invincible: bool = false            # 无敌状态

# 二段跳参数
@export var max_jumps: int = 2          # 最大跳跃次数
var jump_count: int = 0                  # 已使用的跳跃次数

# 攀墙参数
@export var wall_slide_speed: float = 100.0  # 攀墙下降速度
@export var wall_climb_speed: float = 200.0  # 攀墙上升速度

# 钩爪参数
@export var grapple_speed: float = 600.0     # 钩爪拉拽速度
@export var grapple_range: float = 500.0     # 钩爪最大范围
var grapple_target: Vector2 = Vector2.ZERO    # 钩爪目标点
var is_grappling: bool = false                # 是否正在钩爪

# 攻击参数
@export var attack_cooldown: float = 0.3       # 攻击冷却时间
@export var attack_damage: int = 1             # 攻击伤害
@export var attack_range: float = 80.0         # 攻击范围
var can_attack: bool = true                    # 能否攻击
var is_attacking: bool = false                 # 是否正在攻击
var facing_direction: int = 1                  # 面向方向（1=右，-1=左）

# 技能效果参数
var drain_process_active: bool = false       # 算力汲取激活
var is_dashing: bool = false                  # 冲刺中

# 攻击特效
@onready var attack_effect: ColorRect = $AttackEffect

func _ready() -> void:
	current_health = max_health
	attack_effect.visible = false
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_grappling:
		_grapple_update(delta)
		return

	if is_dashing:
		_dash_update(delta)
		return

	velocity.y += gravity * delta

	var input_direction := Input.get_axis("move_left", "move_right")
	velocity.x = input_direction * speed

	if input_direction != 0:
		facing_direction = 1 if input_direction > 0 else -1

	var on_wall := is_on_wall()
	var wall_dir := get_wall_normal()

	if on_wall:
		if Input.is_action_pressed("jump"):
			velocity.y = -wall_climb_speed
		else:
			velocity.y = min(velocity.y, wall_slide_speed)
		jump_count = 0

	if Input.is_action_just_pressed("attack") and can_attack:
		_attack()

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_force
			jump_count = 1
		elif on_wall:
			velocity.y = jump_force
			velocity.x = wall_dir.x * speed * 1.5
			jump_count = 1
		elif jump_count < max_jumps:
			velocity.y = jump_force
			jump_count += 1

	if Input.is_action_just_pressed("grapple"):
		_try_start_grapple()

	if is_on_floor():
		jump_count = 0

	move_and_slide()
	_check_enemy_collision()

func _check_enemy_collision() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var distance := global_position.distance_to(enemy.global_position)
		if distance < 30 and not invincible:
			enemy.hit_player(self)

func take_damage(amount: int) -> void:
	if invincible or current_health <= 0:
		return

	current_health -= amount
	print("玩家受伤！剩余生命: ", current_health)

	if current_health <= 0:
		die()
	else:
		invincible = true
		await get_tree().create_timer(1.0).timeout
		invincible = false

func die() -> void:
	print("玩家死亡！")
	GameManager.player_died()

	# 记录位置用于复活
	var spawn_pos: Vector2 = Vector2(100, 200)

	# 短暂显示死亡效果后复活
	await get_tree().create_timer(1.0).timeout

	# 重置玩家状态
	current_health = max_health
	invincible = true
	global_position = spawn_pos

	await get_tree().create_timer(2.0).timeout
	invincible = false

	# 通知UI更新
	GameManager.game_reset.emit()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)

# ============ 攻击 ============

func _attack() -> void:
	can_attack = false
	is_attacking = true
	_show_attack_effect()
	_attempt_damage()
	await get_tree().create_timer(0.2).timeout
	can_attack = true
	is_attacking = false

func _show_attack_effect() -> void:
	attack_effect.position.x = 32 if facing_direction > 0 else -80
	attack_effect.visible = true
	await get_tree().create_timer(0.15).timeout
	attack_effect.visible = false

func _attempt_damage() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var distance := global_position.distance_to(enemy.global_position)
		if distance < attack_range:
			var to_enemy: Vector2 = enemy.global_position - global_position
			var dot_product: float = to_enemy.normalized().dot(Vector2.RIGHT * facing_direction)
			if dot_product > 0.3:
				if enemy.has_method("take_damage"):
					enemy.take_damage(attack_damage)

# ============ 钩爪 ============

func _try_start_grapple() -> void:
	var grapple_points = get_tree().get_nodes_in_group("grapple_points")
	if grapple_points.is_empty():
		return

	var closest_point: Node2D = null
	var closest_distance: float = grapple_range

	for point in grapple_points:
		var distance := global_position.distance_to(point.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_point = point

	if closest_point:
		is_grappling = true
		grapple_target = closest_point.global_position
		velocity = Vector2.ZERO

func _grapple_update(delta: float) -> void:
	var direction := (grapple_target - global_position).normalized()
	velocity = direction * grapple_speed
	move_and_slide()

	var distance_to_target := global_position.distance_to(grapple_target)
	if distance_to_target < 30 or is_on_wall() or is_on_floor():
		is_grappling = false
		velocity = Vector2.ZERO

# ============ 技能效果 ============

# 冲锋斩
func dash_strike() -> void:
	if is_dashing:
		return
	is_dashing = true
	invincible = true

	var dash_dir := Vector2.RIGHT * facing_direction
	velocity = dash_dir * 800
	attack_damage = 2  # 冲锋时伤害翻倍

	await get_tree().create_timer(0.15).timeout
	is_dashing = false
	invincible = false
	attack_damage = 1

func _dash_update(delta: float) -> void:
	move_and_slide()

# 弹幕格挡
func bullet_bloom() -> void:
	# 创建格挡特效
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var distance := global_position.distance_to(enemy.global_position)
		if distance < 80:
			if enemy.has_method("take_damage"):
				enemy.take_damage(1)

# 紧急闪避
func evasion_protocol() -> void:
	invincible = true
	var blink_dir := Vector2.RIGHT * facing_direction
	global_position += blink_dir * 150

	await get_tree().create_timer(0.5).timeout
	invincible = false
