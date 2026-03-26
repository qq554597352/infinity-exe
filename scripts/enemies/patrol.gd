extends CharacterBody2D
class_name Patrol

# 移动参数
@export var speed: float = 80.0       # 移动速度
@export var max_health: int = 3       # 最大生命值
@export var damage: int = 1           # 伤害
@export var token_drop: int = 5       # 击杀奖励Token

# 巡逻参数
@export var patrol_distance: float = 100.0  # 巡逻距离
var start_position: Vector2 = Vector2.ZERO
var move_direction: int = 1               # 移动方向（1=右，-1=左）

var current_health: int
var is_dead: bool = false
var is_hurt: bool = false                 # 受伤状态

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: ColorRect = $ColorRect

func _ready() -> void:
	current_health = max_health
	start_position = global_position
	health_bar.max_value = max_health
	health_bar.value = current_health

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

	# 检测与玩家的碰撞
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is PlayerController:
			collision.get_collider().take_damage(damage)

func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	health_bar.value = current_health
	print("敌人受伤！剩余生命: ", current_health)

	# 受伤效果 - 闪烁
	_hurt_effect()

	if current_health <= 0:
		die()

func _hurt_effect() -> void:
	is_hurt = true
	# 改变颜色为白色表示受伤
	sprite.color = Color(1, 1, 1, 1)

	# 等待后恢复
	await get_tree().create_timer(0.1).timeout
	sprite.color = Color(1, 0.2, 0.2, 1)
	is_hurt = false

func die() -> void:
	is_dead = true
	print("敌人死亡！获得 ", token_drop, " Token")
	# 通知GameManager增加Token
	if GameManager:
		GameManager.add_token(token_drop)
	# 移除敌人
	queue_free()
