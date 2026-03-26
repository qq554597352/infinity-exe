extends Area2D

# 可拾取的技能碎片
# 敌人死亡后掉落

var fragment_data: Dictionary = {}
var bob_height: float = 5.0
var bob_speed: float = 2.0
var bob_offset: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# 连接到区域进入信号
	body_entered.connect(_on_body_entered)

	# 初始化碎片数据
	fragment_data = SkillManager.generate_skill_fragment()

	if not fragment_data.is_empty():
		sprite.modulate = Color(0, 1, 1, 1)  # 青色表示技能碎片

	# 上下浮动动画
	bob_offset = position.y

func _process(delta: float) -> void:
	# 上下浮动效果
	bob_offset += delta * bob_speed * 10.0
	position.y = bob_height + sin(bob_offset) * 3.0

	# 旋转效果
	rotation += delta * 0.5

func _on_body_entered(body: Node) -> void:
	if body is PlayerController:
		if not fragment_data.is_empty():
			print("拾取技能碎片: ", fragment_data.get("name", ""))
			# 碎片被拾取后消失
			queue_free()
		else:
			queue_free()
