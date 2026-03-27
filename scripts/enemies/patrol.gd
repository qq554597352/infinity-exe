extends CharacterBody2D
class_name Patrol

# 移动参数
@export var speed: float = 80.0       # 移动速度
@export var max_health: int = 3       # 最大生命值
@export var damage: int = 1           # 伤害
@export var token_drop: int = 5       # 击杀奖励Token

# 掉落参数
@export var skill_drop_chance: float = 0.3  # 30%几率掉落技能碎片

# 巡逻参数
@export var patrol_distance: float = 100.0  # 巡逻距离
var start_position: Vector2 = Vector2.ZERO
var move_direction: int = 1               # 移动方向（1=右，-1=左）

var current_health: int
var is_dead: bool = false

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: ColorRect = $ColorRect

func _ready() -> void:
	current_health = max_health
	start_position = global_position
	health_bar.max_value = max_health
	health_bar.value = current_health

	# 加入敌人组
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 巡逻移动
	velocity.x = speed * move_direction
	move_and_slide()

	# 检查是否到达巡逻边界
	var distance_from_start := global_position.x - start_position.x
	if abs(distance_from_start) >= patrol_distance:
		move_direction *= -1  # 反向

func hit_player(player: PlayerController) -> void:
	if is_dead:
		return
	player.take_damage(damage)

func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	health_bar.value = current_health
	print("敌人受伤！剩余生命: ", current_health)

	# 受伤效果
	_hurt_effect()

	if current_health <= 0:
		die()

func _hurt_effect() -> void:
	sprite.color = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.color = Color(1, 0.2, 0.2, 1)

func die() -> void:
	is_dead = true
	print("敌人死亡！获得 ", token_drop, " Token")
	if GameManager:
		GameManager.add_token(token_drop)

	# 30%几率掉落技能碎片
	if randf() < skill_drop_chance:
		_spawn_skill_fragment()

	queue_free()

func _spawn_skill_fragment() -> void:
	# 创建技能碎片
	var fragment = load("res://scenes/items/skill_fragment.tscn").instantiate()
	fragment.position = global_position
	fragment.position.y += 10  # 在敌人脚下生成，方便拾取
	get_parent().add_child(fragment)
	print("掉落技能碎片！")
