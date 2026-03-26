extends GutTest

var game_manager: Node

func before_each():
    game_manager = load("res://scripts/autoload/game_manager.gd").new()
    add_child(game_manager)

func after_each():
    game_manager.free()

func test_initial_token_is_zero():
    assert_eq(game_manager.token, 0, "Initial token should be 0")

func test_add_token():
    game_manager.add_token(10)
    assert_eq(game_manager.token, 10, "Token should be 10 after adding")

func test_remove_token():
    game_manager.token = 50
    var result = game_manager.remove_token(30)
    assert_true(result, "Should return true when enough token")
    assert_eq(game_manager.token, 20, "Token should be 20 after removing")

func test_remove_token_insufficient():
    game_manager.token = 10
    var result = game_manager.remove_token(30)
    assert_false(result, "Should return false when insufficient token")
    assert_eq(game_manager.token, 10, "Token should remain 10")

func test_reset_token():
    game_manager.token = 100
    game_manager.reset_token()
    assert_eq(game_manager.token, 0, "Token should be reset to 0")
