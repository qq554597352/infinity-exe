extends CanvasLayer

@onready var token_label: Label = $TokenLabel

func _ready() -> void:
	# 连接Token变化信号
	GameManager.token_changed.connect(_on_token_changed)
	token_label.text = "Token: " + str(GameManager.token)

func _on_token_changed(new_amount: int) -> void:
	token_label.text = "Token: " + str(new_amount)
