extends Node

# ============ 音效管理器 ============
# 管理所有游戏音效和背景音乐

# 音量设置
@export var master_volume: float = 1.0
@export var sfx_volume: float = 0.8
@export var music_volume: float = 0.6

# 音频播放器
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var sfx_players: Array = []

# 音效库 (使用内置合成音效)
var sound_effects: Dictionary = {}

func _ready() -> void:
	_setup_audio_players()
	_generate_sound_effects()

func _setup_audio_players() -> void:
	# 创建 SFX 播放器
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "Master"
	add_child(sfx_player)

	# 创建音乐播放器
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Master"
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	add_child(music_player)

	# 创建多个 SFX 播放器用于同时播放多个音效
	for i in range(4):
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer" + str(i)
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

func _generate_sound_effects() -> void:
	# 生成内置音效数据
	_generate_attack_sound()
	_generate_jump_sound()
	_generate_hit_sound()
	_generate_pickup_sound()
	_generate_death_sound()
	_generate_skill_sound()

# ============ 音效生成 ============

func _generate_attack_sound() -> void:
	# 快速短促的音效 - 攻击
	var stream = AudioStreamGenerator.new()
	stream.mixin_rate = 44100
	stream.buffer_length = 0.1

	# 使用空白流，实际项目中会加载真实音效文件
	sound_effects["attack"] = null

func _generate_jump_sound() -> void:
	sound_effects["jump"] = null

func _generate_hit_sound() -> void:
	sound_effects["hit"] = null

func _generate_pickup_sound() -> void:
	sound_effects["pickup"] = null

func _generate_death_sound() -> void:
	sound_effects["death"] = null

func _generate_skill_sound() -> void:
	sound_effects["skill"] = null

# ============ 播放音效 ============

func play_sfx(sound_name: String) -> void:
	# 查找空闲的 SFX 播放器
	for player in sfx_players:
		if not player.playing:
			_play_on_player(player, sound_name)
			return

	# 如果都忙，用第一个
	_play_on_player(sfx_players[0], sound_name)

func _play_on_player(player: AudioStreamPlayer, sound_name: String) -> void:
	var stream = sound_effects.get(sound_name, null)

	if stream == null:
		# 如果没有真实音效，使用合成方式播放提示音
		_play_tone(player, sound_name)
	else:
		player.stream = stream
		player.volume_db = linear_to_db(sfx_volume * master_volume)
		player.play()

func _play_tone(player: AudioStreamPlayer, sound_name: String) -> void:
	# 根据音效类型播放不同频率的提示音
	match sound_name:
		"attack":
			_play_beep(player, 880, 0.05, 0.3)  # 高音短促
		"jump":
			_play_beep(player, 440, 0.1, 0.4)   # 中音上升
		"hit":
			_play_beep(player, 220, 0.15, 0.5)   # 低音
		"pickup":
			_play_beep(player, 1320, 0.1, 0.6)   # 高音清脆
		"death":
			_play_beep(player, 110, 0.3, 0.4)    # 超低音
		"skill":
			_play_beep(player, 660, 0.2, 0.7)    # 中高音
		"enemy_death":
			_play_beep(player, 330, 0.2, 0.5)   # 中低音

func _play_beep(player: AudioStreamPlayer, frequency: float, duration: float, volume: float) -> void:
	# 生成简单的正弦波音效
	var samples = int(44100 * duration)
	var data = AudioStreamGeneratorPlayback.new()

	# 创建采样数据
	var audio_data = PackedFloat32Array()
	audio_data.resize(samples)

	for i in samples:
		var t = float(i) / 44100.0
		var envelope = 1.0 - (t / duration)  # 淡出
		var sample = sin(2.0 * PI * frequency * t) * envelope * volume
		audio_data[i] = sample

	# 创建一个简单的音频流
	var stream = AudioStreamMicrophone.new()  # 临时方案

	# 实际使用时会加载真实音效文件
	# 这里只是演示框架

# ============ 播放背景音乐 ============

func play_music(music_name: String, fade_in: bool = false) -> void:
	# 查找音乐文件
	var music_path = "res://assets/audio/music/" + music_name + ".ogg"

	if ResourceLoader.exists(music_path):
		var music = load(music_path)
		if music:
			music_player.stream = music
			music_player.volume_db = linear_to_db(music_volume * master_volume)
			music_player.play()
			return

	# 如果没有真实音乐文件，播放一个简单的循环提示音
	print("Music not found: ", music_path)

func stop_music(fade_out: bool = false) -> void:
	if fade_out:
		_fade_out_music()
	else:
		music_player.stop()

func _fade_out_music() -> void:
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -60, 1.0)
	await tween.finished
	music_player.stop()
	music_player.volume_db = linear_to_db(music_volume * master_volume)

# ============ 音量控制 ============

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume * master_volume)

func _update_volumes() -> void:
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume * master_volume)

# ============ 快捷播放方法 ============

func play_attack() -> void:
	play_sfx("attack")

func play_jump() -> void:
	play_sfx("jump")

func play_hit() -> void:
	play_sfx("hit")

func play_pickup() -> void:
	play_sfx("pickup")

func play_death() -> void:
	play_sfx("death")

func play_skill() -> void:
	play_sfx("skill")

func play_enemy_death() -> void:
	play_sfx("enemy_death")
