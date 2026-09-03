class_name SpatialFeedbackController
extends Node3D

const MIX_RATE := 22050
const BASE_RING_ALPHA := 0.12
const PULSE_RING_ALPHA := 0.46
const FOV_KICK := 1.1

var cue_count: int = 0
var last_cued_state: int = 0
var last_direction: int = 0

var _camera: Camera3D
var _world_state: WorldStateController
var _base_fov: float = 72.0
var _rings: Array[MeshInstance3D] = []
var _ring_materials: Array[StandardMaterial3D] = []
var _ring_tweens: Array[Tween] = []
var _camera_tween: Tween
var _audio_player: AudioStreamPlayer


func configure(
	camera: Camera3D,
	world_state: WorldStateController,
	thresholds: PackedFloat32Array,
	edge_radius: float
) -> void:
	_camera = camera
	_world_state = world_state
	_base_fov = camera.fov
	_build_threshold_seams(thresholds, edge_radius)
	_build_audio()
	_world_state.world_state_changed.connect(_on_world_state_changed)


func _on_world_state_changed(previous: int, current: int) -> void:
	var forward := current > previous
	var crossed_ring := maxi(previous, current) - 1
	if crossed_ring >= 0 and crossed_ring < _rings.size():
		_pulse_ring(crossed_ring, forward)
	_pulse_camera(forward)
	_play_state_cue(current, forward)
	cue_count += 1
	last_cued_state = current
	last_direction = 1 if forward else -1


func _build_threshold_seams(thresholds: PackedFloat32Array, edge_radius: float) -> void:
	var colors := [
		Color(0.25, 0.88, 0.82),
		Color(0.54, 0.62, 1.0),
		Color(1.0, 0.62, 0.28),
	]
	for index in thresholds.size():
		var radius := edge_radius * thresholds[index]
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(colors[index], BASE_RING_ALPHA)
		material.emission_enabled = true
		material.emission = colors[index] * 0.35
		material.emission_energy_multiplier = 0.65
		material.render_priority = 1

		var torus := TorusMesh.new()
		torus.inner_radius = radius - 0.045
		torus.outer_radius = radius + 0.045
		torus.rings = 96
		torus.ring_segments = 6
		torus.material = material
		var ring := MeshInstance3D.new()
		ring.name = "SpatialSeam%d" % (index + 1)
		ring.mesh = torus
		ring.position.y = 0.035
		add_child(ring)
		_rings.append(ring)
		_ring_materials.append(material)
		_ring_tweens.append(null)


func _build_audio() -> void:
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "SpatialTransitionAudio"
	_audio_player.volume_db = -18.0
	add_child(_audio_player)


func _pulse_ring(index: int, forward: bool) -> void:
	var ring := _rings[index]
	var material := _ring_materials[index]
	if is_instance_valid(_ring_tweens[index]):
		_ring_tweens[index].kill()
	ring.scale = Vector3.ONE
	ring.position.y = 0.035
	var base_color := material.albedo_color
	base_color.a = BASE_RING_ALPHA
	var pulse_color := base_color.lightened(0.28) if forward else base_color.darkened(0.12)
	pulse_color.a = PULSE_RING_ALPHA
	material.albedo_color = pulse_color

	var tween := create_tween().set_parallel(true)
	_ring_tweens[index] = tween
	var target_scale := Vector3.ONE * (1.012 if forward else 0.988)
	tween.tween_property(ring, "scale", target_scale, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "position:y", 0.08, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color", base_color, 0.52).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(ring, "scale", Vector3.ONE, 0.28).set_trans(Tween.TRANS_SINE)
	tween.tween_property(ring, "position:y", 0.035, 0.28).set_trans(Tween.TRANS_SINE)


func _pulse_camera(forward: bool) -> void:
	if not is_instance_valid(_camera):
		return
	if is_instance_valid(_camera_tween):
		_camera_tween.kill()
	var kicked_fov := _base_fov + (FOV_KICK if forward else -FOV_KICK * 0.65)
	_camera_tween = create_tween()
	_camera_tween.tween_property(_camera, "fov", kicked_fov, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_camera_tween.tween_property(_camera, "fov", _base_fov, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _play_state_cue(state: int, forward: bool) -> void:
	var frequency := 196.0 + float(state) * 55.0
	if not forward:
		frequency *= 0.78
	_audio_player.stream = _make_tone(frequency, 0.22)
	_audio_player.play()


func _make_tone(frequency: float, duration: float) -> AudioStreamWAV:
	var sample_count := int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for index in sample_count:
		var progress := float(index) / float(sample_count)
		var envelope := sin(PI * progress) * (1.0 - progress * 0.3)
		var fundamental := sin(TAU * frequency * float(index) / MIX_RATE)
		var overtone := sin(TAU * frequency * 2.0 * float(index) / MIX_RATE) * 0.1
		var sample := int((fundamental + overtone) * envelope * 7200.0)
		data.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
