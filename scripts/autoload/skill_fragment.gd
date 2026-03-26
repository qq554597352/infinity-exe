extends Area2D

# 可拾取的技能碎片

var fragment_data: Dictionary = {}
var bob_height: float = 5.0
var bob_speed: float = 2.0
var bob_offset: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	fragment_data = SkillManager.generate_skill_fragment()

	if not fragment_data.is_empty():
		modulate = Color(0, 1, 1, 1)

	bob_offset = position.y

func _process(delta: float) -> void:
	bob_offset += delta * bob_speed * 10.0
	position.y = bob_height + sin(bob_offset) * 3.0
	rotation += delta * 0.5

func _on_body_entered(body: Node) -> void:
	if body is PlayerController:
		if not fragment_data.is_empty():
			var skill_name: String = ""
			if "name" in fragment_data:
				skill_name = fragment_data["name"]
			print("拾取技能碎片: ", skill_name)
		queue_free()
