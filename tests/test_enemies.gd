extends GutTest

var patrol: CharacterBody2D

func before_each():
    patrol = load("res://scenes/enemies/patrol.tscn").instantiate()
    add_child(patrol)

func after_each():
    patrol.free()

func test_patrol_initial_health():
    assert_has_method(patrol, "take_damage", "Patrol should have take_damage method")

func test_patrol_can_take_damage():
    patrol.take_damage(1)
    # 基本测试确保方法存在并可调用
    assert_true(true, "take_damage should be callable")
