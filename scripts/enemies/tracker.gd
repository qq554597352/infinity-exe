extends CharacterBody2D
class_name Tracker

# 移动参数
@export var speed: float = 120.0       # 追踪速度（比巡逻敌人快）
@export var max_health: int = 2         # 最大生命值
@export var damage: int = 1             # 接触伤害
@export var token_drop: int = 8         # 击杀奖励Token（比巡逻高）

# 掉落参数
@export var skill_drop_chance: float = 0.4  # 40%几率掉落技能碎片

# 追踪参数
@export var detection_range: float = 400.0  # 检测范围
@export var stop_distance: float = 40.0      # 停止距离（贴近玩家后停止）

# 攻击参数
@export var attack_cooldown: float = 1.5     # 攻击冷却
@export var attack_range: float = 60.0       # 攻击范围

# 状态
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }
var current_state: State = State.IDLE
var current_health: int
var is_dead: bool = false

# 动画/视觉
@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: ColorRect = $ColorRect
@onready var detection_indicator: ColorRect = $DetectionIndicator

# 攻击计时
var can_attack: bool = true
var attack_timer: float = 0.0

# 玩家引用
var player: Node2D = null

func _ready() -> void:
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.visible = false  # 默认隐藏血条

	add_to_group("enemies")
	add_to_group("trackers")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 更新攻击计时
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

	match current_state:
		State.IDLE:
			_idle_state()
		State.CHASE:
			_chase_state(delta)
		State.ATTACK:
			pass  # 攻击状态在动画中处理
		State.HURT:
			_hurt_state()

func _idle_state() -> void:
	velocity = Vector2.ZERO

	# 检测玩家
	player = _find_player()
	if player:
		current_state = State.CHASE
		health_bar.visible = true  # 发现玩家后显示血条
		print("Tracker 发现目标！开始追踪...")

func _chase_state(delta: float) -> void:
	if not player or not is_instance_valid(player):
		current_state = State.IDLE
		health_bar.visible = false
		return

	var direction := global_position.direction_to(player.global_position)
	var distance := global_position.distance_to(player.global_position)

	# 判断距离
	if distance < stop_distance:
		# 贴近玩家，停止移动
		velocity = Vector2.ZERO

		# 尝试攻击
		if can_attack:
			_attack()
	else:
		# 向玩家移动
		velocity = direction * speed

	move_and_slide()

	# 检查是否超出检测范围
	if distance > detection_range * 1.5:
		current_state = State.IDLE
		health_bar.visible = false
		print("Tracker 丢失目标...")
		return

	# 更新面向方向
	if direction.x > 0.1:
		sprite.scale.x = 1
	elif direction.x < -0.1:
		sprite.scale.x = -1

func _hurt_state() -> void:
	# 受伤时停止移动
	velocity = Vector2.ZERO

func _attack() -> void:
	can_attack = false
	attack_timer = attack_cooldown
	current_state = State.ATTACK

	# 播放攻击动画（红色闪烁）
	_attack_effect()

	# 对范围内的玩家造成伤害
	if player and is_instance_valid(player):
		var distance := global_position.distance_to(player.global_position)
		if distance < attack_range:
			player.take_damage(damage)
			print("Tracker 发动攻击！造成 ", damage, " 点伤害")

	await get_tree().create_timer(0.3).timeout
	current_state = State.CHASE

func _attack_effect() -> void:
	# 红色闪烁表示攻击
	sprite.color = Color(1, 0.3, 0.3, 1)
	await get_tree().create_timer(0.15).timeout
	sprite.color = Color(1, 1, 1, 1)

func _find_player() -> Node2D:
	# 从场景树中查找玩家
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var p = players[0]
		var distance := global_position.distance_to(p.global_position)
		if distance < detection_range:
			return p
	return null

func hit_player(player_ref: Node2D) -> void:
	if is_dead:
		return
	player = player_ref

	# 只有在追踪状态才造成伤害
	if current_state == State.CHASE or current_state == State.ATTACK:
		player_ref.take_damage(damage)

func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	health_bar.value = current_health
	print("Tracker 受伤！剩余生命: ", current_health)

	# 受伤效果
	_hurt_effect()

	# 受伤时短暂停顿
	current_state = State.HURT
	await get_tree().create_timer(0.2).timeout
	if current_state == State.HURT:
		current_state = State.CHASE

	if current_health <= 0:
		die()

func _hurt_effect() -> void:
	# 白色闪烁
	sprite.color = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.05).timeout
	sprite.color = Color(0.5, 0.5, 1, 1)  # 蓝色表示受伤

func die() -> void:
	is_dead = true
	print("Tracker 被消灭！获得 ", token_drop, " Token")

	if GameManager:
		GameManager.add_token(token_drop)

	# 50%几率掉落技能碎片（比普通敌人高）
	if randf() < skill_drop_chance:
		_spawn_skill_fragment()

	# 死亡动画
	_death_effect()

	await get_tree().create_timer(0.5).timeout
	queue_free()

func _death_effect() -> void:
	# 消失效果
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.2)

func _spawn_skill_fragment() -> void:
	var fragment = load("res://scenes/items/skill_fragment.tscn").instantiate()
	fragment.position = global_position
	fragment.position.y += 10  # 在敌人脚下生成，方便拾取
	get_parent().add_child(fragment)
	print("Tracker 掉落技能碎片！")
