extends Node

var token: int = 0
var loop_count: int = 0

signal token_changed(new_amount: int)

func add_token(amount: int) -> void:
	token += amount
	token_changed.emit(token)

func remove_token(amount: int) -> bool:
	if token >= amount:
		token -= amount
		token_changed.emit(token)
		return true
	return false

func reset_token() -> void:
	token = 0
	token_changed.emit(token)

func increment_loop() -> void:
	loop_count += 1
