class_name AIController
extends TeamController

var behavior_tree: BehaviorTree = load("res://resources/ai/ai_bt.tres") 

var bt_player: BTPlayer
var bt_blackboard: Blackboard


func _setup() -> void:
	print("init ai controller")

	bt_player = BTPlayer.new()
	bt_player.active = false
	add_child(bt_player)
	bt_player.owner = self

	bt_blackboard = Blackboard.new()

	var instance: BTInstance = behavior_tree.instantiate(self, bt_blackboard, bt_player)
	bt_player.set_bt_instance(instance)


func _play_turn() -> void:
	print('playing turn')
	bt_player.active = true
	var status = await bt_player.behavior_tree_finished
	print('STATUS: ', status)

	_end_turn()


func _end_turn() -> void:
	super._end_turn()

	bt_player.active = false