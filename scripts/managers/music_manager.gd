class_name MusicManager
extends Node


@export var playlist: MusicPlaylist

var music_service: MusicService
var current_track: AudioStream

var fading_out: bool

func setup(ms: MusicService) -> void:
	music_service = ms

	var track: AudioStream = playlist.tracks.pick_random()
	current_track = track
	play()

	music_service.track_finished.connect(_on_track_finished)


func _on_track_finished() -> void:
	play_next()


func play_next() -> void:
	fading_out = false
	current_track = playlist.get_next(current_track)
	play()


func play() -> void:
	music_service.play_track(current_track, playlist.fade_in_time)


func _process(_delta: float) -> void:
	if fading_out:
		return

	fade_out()

func fade_out() -> void:
	var current_seconds: float = music_service.audio_player.get_playback_position()
	var stream_length: float = current_track.get_length()

	if stream_length - current_seconds <= playlist.fade_out_time:
		music_service.fade_out(playlist.fade_out_time)
		fading_out = true
