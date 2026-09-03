class_name PuzzleAudio
extends Node

const MIX_RATE := 22050

var _active_players: Array[AudioStreamPlayer] = []


func play_cue(cue: String) -> void:
	var frequency := 440.0
	var duration := 0.14
	match cue:
		"anchor_revealed":
			frequency = 410.0
			duration = 0.28
		"anchor_acquired":
			frequency = 520.0
			duration = 0.2
		"anchor_applied":
			frequency = 330.0
			duration = 0.24
		"anchor_resist":
			frequency = 275.0
			duration = 0.16
		"fragment":
			frequency = 660.0
			duration = 0.25
		"exit":
			frequency = 780.0
			duration = 0.3
		"complete":
			frequency = 920.0
			duration = 0.42

	var player := AudioStreamPlayer.new()
	player.stream = _make_tone(frequency, duration)
	player.volume_db = -13.0
	player.finished.connect(_on_player_finished.bind(player))
	add_child(player)
	_active_players.append(player)
	player.play()


func _exit_tree() -> void:
	for player in _active_players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_active_players.clear()


func _on_player_finished(player: AudioStreamPlayer) -> void:
	_active_players.erase(player)
	player.stream = null
	player.queue_free()


func _make_tone(frequency: float, duration: float) -> AudioStreamWAV:
	var sample_count := int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for index in sample_count:
		var progress := float(index) / float(sample_count)
		var envelope := sin(PI * progress) * (1.0 - progress * 0.35)
		var sample := int(sin(TAU * frequency * float(index) / MIX_RATE) * envelope * 9000.0)
		data.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
