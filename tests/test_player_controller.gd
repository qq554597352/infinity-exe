extends GutTest

var player: CharacterBody2D

func before_each():
    # 创建测试用的玩家节点
    player = CharacterBody2D.new()
    add_child(player)

func after_each():
    player.free()

func test_player_has_required_properties():
    # 测试玩家有必需的导出变量
    assert_has_property(player, "speed")
    assert_has_property(player, "jump_force")

func test_player_initial_state():
    # 测试玩家初始状态
    assert_eq(player.velocity, Vector2.ZERO, "Initial velocity should be zero")
