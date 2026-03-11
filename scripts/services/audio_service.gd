extends Node

@export var sfx_bus: String = "SFX"

var player_instances: Dictionary = {} # player unique id -> player

func play_sfx(stream: AudioStream, world_pos: Vector2):
	if not stream:
		return

	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = sfx_bus
	player.global_position = world_pos
	add_child(player)

	player.play()
	player.finished.connect(player.queue_free)


func play_loop(stream: AudioStream, world_pos: Vector2) -> int:
	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = sfx_bus
	player.global_position = world_pos
	add_child(player)

	player.play()

	var id: int = player.get_instance_id()
	player_instances[id] = player
	
	return id

func stop(id: int) -> void:
	var player: AudioStreamPlayer2D = player_instances.get(id)
	if player == null:
		return

	player.stop()
	player_instances.erase(id)
	player.queue_free()
